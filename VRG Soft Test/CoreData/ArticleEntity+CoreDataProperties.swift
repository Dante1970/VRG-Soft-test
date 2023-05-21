//
//  ArticleEntity+CoreDataProperties.swift
//  
//
//  Created by Сергей Белоусов on 19.05.2023.
//
//

import Foundation
import CoreData


extension ArticleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        return NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }

    @NSManaged public var abstract: String?
    @NSManaged public var category: String?
    @NSManaged public var imageSmall: Data?
    @NSManaged public var imageBig: Data?
    @NSManaged public var title: String?
    @NSManaged public var updatedDate: String?
    @NSManaged public var url: String?

}
