//
//  ArticleDetailViewController.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 17.05.2023.
//

import UIKit
import SafariServices

class ArticleDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var article: Article? {
        willSet(newArticle) {
            
            guard let newArticle = newArticle else { return }
            
            self.url = newArticle.url
            sourceLabel.text = newArticle.updated
            titleLabel.text = newArticle.title
            abstractLabel.text = newArticle.abstract
        }
    }
    
    var articleEntity: ArticleEntity? {
        willSet(newArticleEntity) {
            
            guard let newArticleEntity = newArticleEntity else { return }
            
            self.url = newArticleEntity.url
            sourceLabel.text = newArticleEntity.updatedDate
            titleLabel.text = newArticleEntity.title
            abstractLabel.text = newArticleEntity.abstract
        }
    }
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let abstractLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private var url: String?
    
    private lazy var stackViewLabels: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sourceLabel, titleLabel, abstractLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let openLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open article in browser", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        getImage(for: article)
    }
    
    // MARK: - Private Methods
    
    @objc
    private func buttonTapped() {
        print("Tapped")
        
        guard let articleURL = url else { return }

        
        if let url = URL(string: articleURL) {
           let safariViewController = SFSafariViewController(url: url)
           present(safariViewController, animated: true, completion: nil)
        }
    }
    
    private func getImage(for article: Article?) {
        
        if article != nil {
            ApiManager.shared.getImage(from: article, pictureSize: .big) { [weak self] image in
                guard let self = self else { return }
                self.mainImageView.image = image
            }
        } else {
            CoreDataManager.shared.getImage(from: articleEntity, pictureSize: .big) { [weak self] image in
                guard let self = self else { return }
                self.mainImageView.image = image
            }
        }
    }
    
    private func makeUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainImageView)
        view.addSubview(stackViewLabels)
        view.addSubview(openLinkButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        stackViewLabels.translatesAutoresizingMaskIntoConstraints = false
        openLinkButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250),
            
            stackViewLabels.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 5),
            stackViewLabels.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewLabels.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            openLinkButton.topAnchor.constraint(equalTo: stackViewLabels.bottomAnchor, constant: 5),
            openLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
