//
//  MultipleImageLoadView.swift
//  AsyncAwaitWithSwiftUI
//
//  Created by Minho on 5/8/24.
//

import SwiftUI

struct MultipleImageLoadView: View {
    
    @State var images: [UIImage] = []
    @State var isImageLoading = false
    
    var body: some View {
        Text("Tap to load multiple images")
            .font(.title2)
            .bold()
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.fixed(300))], content: {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .skeleton(with: isImageLoading, shape: .rectangle)
                        .frame(width: 300, height: 300)
                        .clipShape(.buttonBorder)
                        
                }
            })
        }
        loadButton
    }
    
    func asyncImageLoad() async {
        do {
            isImageLoading = true
            images = try await AsyncImageLoader.shared.fetchImages(count: 3)
            isImageLoading = false
        } catch {
            print(error)
        }
    }
    
    var loadButton: some View {
        Button("Load") {
            Task {
                await asyncImageLoad()
            }
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
    MultipleImageLoadView()
}
