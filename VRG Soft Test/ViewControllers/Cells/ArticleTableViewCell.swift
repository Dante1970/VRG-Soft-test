//
//  TableViewCell.swift
//  VRG Soft Test
//
//  Created by Сергей Белоусов on 16.05.2023.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    // MARK: - Properties

    static let identifier = "ArticleTableViewCell"
    
    var article: Article? {
        willSet(newArticle) {
            
            guard let newArticle = newArticle else { return }
            
            titleLabel.text = newArticle.title
        }
    }
    
    private let mainImageView: UIImageView = {
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
        getImageForCell(from: article, pictureSize: .small)
    }
    
    // MARK: - Private Methods
    
    private func getImageForCell(from article: Article?, pictureSize: PictureSize) {
        
        ApiManager.shared.getImage(from: article, pictureSize: pictureSize) { [weak self] image in
            
            guard let self = self else { return }
            
            self.mainImageView.image = image
        }
    }
    
    private func makeUI() {
        contentView.addSubview(mainImageView)
        contentView.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 5
        let mainImageViewSize: CGFloat = 75
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            mainImageView.widthAnchor.constraint(equalToConstant: mainImageViewSize),
            mainImageView.heightAnchor.constraint(equalToConstant: mainImageViewSize),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: padding + 10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
}
