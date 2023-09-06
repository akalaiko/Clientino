//
//  TileCollectionViewCell.swift
//  DropboxClientino
//
//  Created by Tim on 04.09.2023.
//

import UIKit

final class TileCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 10, weight: .bold)
        return label
    }()
    
    private lazy var videoOverlay: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.clipsToBounds = true
        imageView.layer.opacity = 0.8
        return imageView
    }()
    
    private lazy var isVideo: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        label.text = nil
        isVideo = false
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(videoOverlay)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            
            videoOverlay.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            videoOverlay.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            videoOverlay.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5),
            videoOverlay.heightAnchor.constraint(equalTo: videoOverlay.widthAnchor)
        ])
    }

    public func config(image: UIImage, name: String, isVideo: Bool) {
        imageView.image = image
        label.text = name
        videoOverlay.isHidden = !isVideo
    }
}
