//
//  MostSharedViewController.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import UIKit

class MostSharedViewController: UIViewController {

    // MARK: - Properties
    
    private var articles: [Article] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        makeUI()
        
        getMostSharedArticles()
    }
    
    // MARK: - Private Methods
    
    private func toggleFavoriteState(for cell: ArticleTableViewCell, at indexPath: IndexPath) {
        let article = self.articles[indexPath.row]
        
        CoreDataManager.shared.toggleFavoriteState(for: article, category: .mostShared) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func getMostSharedArticles() {
        
        ApiManager.shared.getArticles(for: .mostShared(days: .lastMonth)) { result in
            switch result {
            case .success(let mostSharedArticles):
                self.articles = mostSharedArticles
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func makeUI() {
        navigationController!.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Most Shared"
        
        view.addSubview(tableView)
    }
}

// MARK: - Extension

extension MostSharedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell
        
        guard let cell = cell else { return UITableViewCell() }
        
        let url = articles[indexPath.row].url
        CoreDataManager.shared.isInFavorites(url: url) { result in
            cell.isInFavorites = result
        }
        
        cell.article = articles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let articleDetailVC = ArticleDetailViewController()
        articleDetailVC.article = articles[indexPath.row]
        
        navigationController?.pushViewController(articleDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! ArticleTableViewCell
        
        let imageBookmarkFill = UIImage(systemName: "bookmark.fill")
        let imageBookmark = UIImage(systemName: "bookmark")
        
        let swipeFavorite = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, success in
            guard let self = self else { return }
            self.toggleFavoriteState(for: cell, at: indexPath)
        }
        
        swipeFavorite.image = cell.isInFavorites ? imageBookmarkFill : imageBookmark
        swipeFavorite.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [swipeFavorite])
    }
}
