//
//  ApiManager.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import Foundation
import Alamofire

class ApiManager {
    
    // MARK: - Properties
    
    static let shared = ApiManager()
    
    private let baseURL = "https://api.nytimes.com/svc/mostpopular/v2"
    private let apiKey = "ZxPuLNHQZ4QhlloSUGkLOK4NTdMymzGz"
    private let noImage = UIImage(systemName: "camera.metering.unknown")
    
    // MARK: - Public Methods
    
    // Get articles for the given API type
    func getArticles(for apiType: ApiType, completion: @escaping (Result<[Article], Error>) -> ()) {
        
        let urlString = "\(baseURL)/\(apiType.section)/\(apiType.days.value).json?api-key=\(apiKey)"
        
        AF.request(urlString)
            .validate()
            .response { response in
                do {
                    guard let data = response.data else {
                        throw response.error ?? ErrorManager.errorDecode
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let articlesResult = try decoder.decode(ArticlesResult.self, from: data)
                    
                    guard let articles = articlesResult.results else {
                        throw ErrorManager.resultsIsNil
                    }
                    
                    completion(.success(articles))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // Get the image for the article with the specified size
    func getImage(from article: Article?, pictureSize: PictureSize, completion: @escaping (UIImage) -> ()) {
        
        guard let url = validationImageURL(for: article, pictureSize: pictureSize) else {
            print("No image data")
            completion(noImage!)
            return
        }
        
        AF.download(url).responseData { response in
            
            guard let data = response.value,
                  let image = UIImage(data: data)
            else {
                print("Image download failed")
                completion(self.noImage!)
                return
            }
            
            completion(image)
        }
    }

    // Validate and retrieve the image URL for the article and picture size
    func validationImageURL(for article: Article?, pictureSize: PictureSize) -> String? {
        
        if let article = article,
           let media = article.media,
           media.indices.contains(0),
           let mediaMetadata = media[0].mediaMetadata,
           mediaMetadata.indices.contains(0),
           let url = mediaMetadata[pictureSize.rawValue].url {
            return url
        } else {
            print("Error: Failed to get URL")
            return nil
        }
    }
}
