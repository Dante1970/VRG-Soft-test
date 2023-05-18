//
//  ApiManager.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import Foundation
import Alamofire

// MARK: - ApiType

enum ApiType {
    case mostEmailed(days: Days)
    case mostShared(days: Days)
    case mostViewed(days: Days)
    
    enum Days {
        case lastDay
        case lastWeek
        case lastMonth
        
        var value: Int {
            switch self {
            case .lastDay: return 1
            case .lastWeek: return 7
            case .lastMonth: return 30
            }
        }
    }
    
    var section: String {
        switch self {
        case .mostEmailed: return "emailed"
        case .mostShared: return "shared"
        case .mostViewed: return "viewed"
        }
    }
    
    var days: Days {
        switch self {
        case .mostEmailed(let days): return days
        case .mostShared(let days): return days
        case .mostViewed(let days): return days
        }
    }
}

// MARK: - ErrorManager

enum ErrorManager: Error {
    case errorDecode
    case resultsIsNil
}

// MARK: - PictureSize

enum PictureSize: Int {
    case small = 0
    case medium = 1
    case big = 2
}

// MARK: - ApiManager

class ApiManager {
    
    // MARK: - Properties
    
    static let shared = ApiManager()
    
    private let baseURL = "https://api.nytimes.com/svc/mostpopular/v2"
    private let apiKey = "ZxPuLNHQZ4QhlloSUGkLOK4NTdMymzGz"
    private let noImage = UIImage(systemName: "camera.metering.unknown")
    
    // MARK: - Public Methods
    
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
