//
//  AsyncImageLoader.swift
//  AsyncAwaitWithSwiftUI
//
//  Created by Minho on 5/8/24.
//

import Foundation
import UIKit

enum ImageLoadError: Error {
    case invalidUrl
    case invalidResponse
    case invalidImage
    case unknown
    
    var description: String {
        switch self {
        case .invalidUrl:
            return "유효하지 않은 URL이 입력되었습니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .invalidImage:
            return "올바르지 않은 이미지입니다."
        case .unknown:
            return "알 수 없는 에러입니다."
        }
    }
}

final class AsyncImageLoader {
    
    static let shared = AsyncImageLoader()
    
    private init() {}
    
    // URLSession 사용하여 이미지 로드
    func urlSessionImageLoad(imageUrl: URL?, completion: @escaping (Result<UIImage, ImageLoadError>) -> Void) throws {
        
        // 유효하지 않은 URL을 입력한 경우 .invalidUrl 에러를 클로저로 넘기고 조기 종료
        guard let imageUrl else {
            completion(.failure(.invalidUrl))
            return
        }
        
        /*
         useProtocolCachePolicy: protcol 특성에 따른 기본 캐시정책 (서버에서 전달한 Cache-Control 헤더 그대로 따름)
         reloadIgnoringLocalCacheData : local 캐시를 무시하고 항상 네트워크에 접속하도록 설정하는 정책
         returnCacheDataDontLoad : 네트워크에 접속하지 않고 항상 local 캐시를 사용하도록 설정하는 정책
         returnCacheDataElseLoad : local 캐시를 확인하고 캐시가 없는 경우에만 네트워크에 접속하도록 설정하는 정책
         */
        let request = URLRequest(url: imageUrl,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 5)
        
        // DataTask: HTTP의 각종 메서드를 이용해 서버로부터 응답을 받아 Data객체를 가져오는 작업 수행
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data else {
                completion(.failure(.unknown))
                return
            }
            
            guard error == nil else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidImage))
                return
            }
            
            completion(.success(image))
        }.resume()
        
    }
    
    func fetchImageAsyncAwait() async throws -> UIImage {
        
        let request = URLRequest(url: URL(string: "https://picsum.photos/300")!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw ImageLoadError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoadError.invalidImage
        }
        
        return image
    }
    
    func fetchImages(count: Int) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            for _ in 0..<count {
                group.addTask {
                    try await AsyncImageLoader.shared.fetchImageAsyncAwait()
                }
            }
            
            var images: [UIImage] = []
            
            for try await image in group {
                images.append(image)
            }
            
            return images
        }
    }
}
