//
//  MostEmailedViewController.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import UIKit

class MostEmailedViewController: UIViewController {
    
    // MARK: - Properties
    
    private var articles: [Article] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        makeUI()
        
        getMostEmailedArticles()
    }
    
    // MARK: - Private Methods
    
    private func getMostEmailedArticles() {
        
        ApiManager.shared.getArticles(for: .mostEmailed(days: .lastMonth)) { result in
            switch result {
            case .success(let mostEmailedArticles):
                self.articles = mostEmailedArticles
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func makeUI() {
        navigationController!.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Most Emailed"
        
        view.addSubview(tableView)
    }
}

// MARK: - Extension

extension MostEmailedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell
        
        guard let cell = cell else { return UITableViewCell() }
        
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
        
        let swipeFavorite = UIContextualAction(style: .normal, title: nil) { action, view, success in
            print("add to favorite")
        }
        swipeFavorite.image = UIImage(systemName: "bookmark")
        swipeFavorite.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [swipeFavorite])
    }
}
