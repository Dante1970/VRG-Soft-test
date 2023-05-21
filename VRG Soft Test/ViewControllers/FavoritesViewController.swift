//
//  FavoritesViewController.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    
    private var articlesEntity: [ArticleEntity] = []
    private let categories: [String] = ["Most Emailed", "Most Shared", "Most Viewed"]

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        makeUI()
    }
    
    // MARK: - viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        
        articlesEntity = CoreDataManager.shared.getFavoritesArticles()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func makeUI() {
        navigationController!.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Most Favorites"
        
        view.addSubview(tableView)
    }
    
    private func deleteFromFavorites(for cell: ArticleTableViewCell, at indexPath: IndexPath) {
        
        guard let url = cell.articleEntity?.url else {
            print("Error! articleEntity url is nil.")
            return
        }
        
        CoreDataManager.shared.deleteFromFavorites(url: url)
    }
    
    func getArticleEntity(for indexPath: IndexPath) -> ArticleEntity? {
        let category = categories[indexPath.section]
        let filteredArticles = articlesEntity.filter { $0.category == category }
        guard indexPath.row < filteredArticles.count else {
            return nil
        }
        return filteredArticles[indexPath.row]
    }
}

// MARK: - Extension

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        let filteredArticles = articlesEntity.filter { $0.category == category }
        return filteredArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as! ArticleTableViewCell
        
        let articleEntity = getArticleEntity(for: indexPath)
        
        cell.articleEntity = articleEntity
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let articleDetailVC = ArticleDetailViewController()
        let articleEntity = getArticleEntity(for: indexPath)
        
        articleDetailVC.articleEntity = articleEntity
        
        navigationController?.pushViewController(articleDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! ArticleTableViewCell
        
        let imageBookmarkFill = UIImage(systemName: "bookmark.fill")
        
        let swipeFavorite = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, success in
            guard let self = self else { return }
            
            self.deleteFromFavorites(for: cell, at: indexPath)
            self.tableView.reloadData()
        }

        swipeFavorite.image = imageBookmarkFill
        swipeFavorite.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [swipeFavorite])
    }
}
