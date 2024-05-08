//
//  ContentView.swift
//  AsyncAwaitWithSwiftUI
//
//  Created by Minho on 5/8/24.
//

import SwiftUI
import SkeletonUI

struct ContentView: View {
    
    let imageUrl = URL(string: "https://picsum.phoos/200")
    @State var isImageLoading = false
    @State var loadedImage: UIImage?
    
    var body: some View {
        VStack {
            Image(uiImage: loadedImage ?? UIImage(systemName: "photo")!)
                .skeleton(with: isImageLoading,
                          shape: .rectangle)
                .frame(width: 200, height: 200)
            Button("이미지 로딩") {
                isImageLoading = true
                asyncImageLoad()
            }
            .foregroundStyle(.white)
            .padding(8)
            .background(.blue)
            .clipShape(.buttonBorder)
            
        }
        .padding()
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
                    isImageLoading = false
                }
            }
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
