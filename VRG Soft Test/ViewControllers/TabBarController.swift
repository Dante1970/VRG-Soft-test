//
//  TabBarController.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - enum TabBarItem
    
    // Enumeration representing tab bar items
    private enum TabBarItem: Int {
        case mostEmailed
        case mostShared
        case mostViewed
        case favorites
        
        var title: String {
            // Return the title for each tab bar item
            switch self {
            case .mostEmailed:
                return "Most Emailed"
            case .mostShared:
                return "Most Shared"
            case .mostViewed:
                return "MostViewed"
            case .favorites:
                return "Favorites"
            }
        }
        
        var iconName: String {
            // Return the system name of the icon for each tab bar item
            switch self {
            case .mostEmailed:
                return "envelope.fill"
            case .mostShared:
                return "square.and.arrow.up.fill"
            case .mostViewed:
                return  "eye.fill"
            case .favorites:
                return "bookmark.fill"
            }
        }
    }
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the tab bar
        self.setupTabBar()
    }
    
    // MARK: - Private Methods
    
    private func setupTabBar() {
        
        let dataSource: [TabBarItem] = [.mostEmailed, .mostShared, .mostViewed, .favorites]
        
        // Create view controllers for each tab bar item
        self.viewControllers = dataSource.map {
            
            switch $0 {
            case .mostEmailed:
                let mostEmailedViewController = MostEmailedViewController()
                return self.wrappedInNavigationController(with: mostEmailedViewController, title: $0.title)
                
            case .mostShared:
                let mostSharedViewController = MostSharedViewController()
                return self.wrappedInNavigationController(with: mostSharedViewController, title: $0.title)
                
            case .mostViewed:
                let mostViewedViewController = MostViewedController()
                return self.wrappedInNavigationController(with: mostViewedViewController, title: $0.title)
                
            case .favorites:
                let favoritesViewController = FavoritesViewController()
                return self.wrappedInNavigationController(with: favoritesViewController, title: $0.title)
            }
        }
        
        // Set tab bar item titles and icons for each view controller
        self.viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = dataSource[$0].title
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
            $1.tabBarItem.imageInsets = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
        }
    }
    
    private func wrappedInNavigationController(with: UIViewController, title: String) -> UINavigationController {
        // Wrap a view controller in a navigation controller
        return UINavigationController(rootViewController: with)
    }
}
