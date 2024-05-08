//
//  ContentView.swift
//  AsyncAwaitWithSwiftUI
//
//  Created by Minho on 5/8/24.
//

import SwiftUI
import SkeletonUI
import AlertToast

struct ContentView: View {
    
    let imageUrl = URL(string: "https://picsum.photos/300")
    @State var loadedImage: UIImage?
    @State var isImageLoading = false
    @State var showToast = false
    @State var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Tap to load image")
                .font(.title)
                .bold()
            imageView
            Spacer()
                .frame(height: 64)
            loadButton
        }
        .padding()
        .toast(isPresenting: $showToast) {
            AlertToast(displayMode: .banner(.pop),
                       type: .error(.red), title: errorMessage)
        }
    }
    
    func asyncImageLoad() {
        do {
            try AsyncImageLoader.shared.urlSessionImageLoad(imageUrl: imageUrl) { response in
                switch response {
                case .success(let image):
                    loadedImage = image
                    isImageLoading = false
                case .failure(let error):
                    print(error)
                    errorMessage = error.description
                    showToast = true
                    isImageLoading = false
                }
            }
        } catch {
            print(error)
        }
    }
    
    var imageView: some View {
        Image(uiImage: loadedImage ?? UIImage(systemName: "photo")!)
            .skeleton(with: isImageLoading,
                      shape: .rectangle)
            .frame(width: 300, height: 300)
            .clipShape(.buttonBorder)
    }
    
    var loadButton: some View {
        Button("Load") {
            isImageLoading = true
            asyncImageLoad()
        }
        .foregroundStyle(.white)
        .padding(16)
        .bold()
        .font(.title2)
        .background(.blue)
        .clipShape(.buttonBorder)
    }
}

#Preview {
    ContentView()
}
