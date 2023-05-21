//
//  CoreDataManager.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 19.05.2023.
//

import Foundation
import CoreData
import UIKit

// MARK: - FavoriteCategories

enum FavoriteCategories: String {
    case mostEmailed = "Most Emailed"
    case mostShared = "Most Shared"
    case mostViewed = "Most Viewed"
}

// MARK: - CoreDataManager

final class CoreDataManager {
    
    // MARK: - Properties
    
    static let shared = CoreDataManager()
    
    private lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private lazy var context = appDelegate.persistentContainer.viewContext
    
    // MARK: - Public Methods
    
    func saveToFavorites(article: Article, imageSmall: UIImage?, imageBig: UIImage?, category: FavoriteCategories) {
        
        let entity = NSEntityDescription.entity(forEntityName: "ArticleEntity", in: context)
        let ArticleEntityObject = NSManagedObject(entity: entity!, insertInto: context) as! ArticleEntity
        ArticleEntityObject.abstract = article.abstract
        ArticleEntityObject.url = article.url
        ArticleEntityObject.title = article.title
        ArticleEntityObject.updatedDate = article.updated
        ArticleEntityObject.imageSmall = imageSmall?.jpegData(compressionQuality: 0.8)
        ArticleEntityObject.imageBig = imageBig?.jpegData(compressionQuality: 0.8)
        ArticleEntityObject.category = category.rawValue
        
        do {
            try context.save()
            print("Saved to favorites successfully!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteFromFavorites(url: String?) {
        
        guard let url = url else {
            print("Error! Url is nil.")
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleEntity")
        let predicate = NSPredicate(format: "url = %@", url)
        fetchRequest.predicate = predicate
        
        do {
            let results = try context.fetch(fetchRequest)
            if let articleEntity = results.first as? ArticleEntity {
                context.delete(articleEntity)
                try context.save()
                print("Deleted from favorites successfully!")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getFavoritesArticles() -> [ArticleEntity] {
        
        var articlesEntity: [ArticleEntity] = []
        
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        
        do {
            let articles = try context.fetch(fetchRequest)
            articlesEntity = articles
        } catch {
            print(error.localizedDescription)
        }
        
        return articlesEntity
    }
    
    func getImage(from articleEntity: ArticleEntity?, pictureSize: PictureSize, completion: @escaping (UIImage?) -> ()) {
        
        let imageData: Data?
        
        switch pictureSize {
        case .small:
            imageData = articleEntity?.imageSmall
        case .medium:
            imageData = nil
            print("We do not save middle pictures yet")
        case .big:
            imageData = articleEntity?.imageBig
        }
        
        guard let imageData = imageData else { return }
        guard let image = UIImage(data: imageData) else { return }
        completion(image)
    }
    
    func isInFavorites(url: String?, completion: @escaping (Bool) -> ()) {
        
        guard let url = url else {
            print("Error! Url is nil.")
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleEntity")
        let predicate = NSPredicate(format: "url = %@", url)
        fetchRequest.predicate = predicate
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func toggleFavoriteState(for article: Article, category: FavoriteCategories) {
        let url = article.url

        ApiManager.shared.getImage(from: article, pictureSize: .small) { [weak self] imageSmall in
            
            ApiManager.shared.getImage(from: article, pictureSize: .big) { [weak self] imageBig in
                
                self?.isInFavorites(url: url) { [weak self] result in
                    if let self = self {
                        if result {
                            self.deleteFromFavorites(url: url)
                        } else {
                            self.saveToFavorites(article: article, imageSmall: imageSmall, imageBig: imageBig, category: category)
                        }
                    }
                }
            }
        }
    }
}
