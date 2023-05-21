//
//  TableViewCell.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import UIKit

enum DataType {
    case apiData
    case coreData
}

class ArticleTableViewCell: UITableViewCell {
    
    // MARK: - Properties

    static let identifier = "ArticleTableViewCell"
    
    var isInFavorites: Bool = false
    var dataType: DataType?
    
    var article: Article? {
        willSet(newArticle) {
            
            guard let newArticle = newArticle else { return }
            
            titleLabel.text = newArticle.title
            dataType = .apiData
        }
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        return indicator
    }()
    
    var articleEntity: ArticleEntity? {
        willSet(newArticleEntity) {
            
            guard let newArticleEntity = newArticleEntity else { return }
            
            titleLabel.text = newArticleEntity.title
            dataType = .coreData
        }
    }
    
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LayoutSubviews
    
    override func layoutSubviews() {
        getImageForCell(dataType: dataType, pictureSize: .small)
    }
    
    // MARK: - Private Methods
    
    private func getImageForCell(dataType: DataType?, pictureSize: PictureSize) {
        
        guard let dataType = dataType else {
            print("Error! No dataType in cell.")
            return
        }
        
        activityIndicator.startAnimating()
        
        switch dataType {
        case .apiData:
            ApiManager.shared.getImage(from: article, pictureSize: pictureSize) { [weak self] image in
                guard let self = self else { return }
                
                self.mainImageView.image = image
                self.activityIndicator.stopAnimating()
            }
        case .coreData:
            CoreDataManager.shared.getImage(from: articleEntity, pictureSize: pictureSize) { [weak self] image in
                guard let self = self else { return }
                
                self.mainImageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func makeUI() {
        contentView.addSubview(mainImageView)
        mainImageView.addSubview(activityIndicator)
        contentView.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 5
        let mainImageViewSize: CGFloat = 75
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            mainImageView.widthAnchor.constraint(equalToConstant: mainImageViewSize),
            mainImageView.heightAnchor.constraint(equalToConstant: mainImageViewSize),
            
            activityIndicator.centerXAnchor.constraint(equalTo: mainImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: padding + 10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
}
