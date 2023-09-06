//
//  PhotoView.swift
//  DropboxClientino
//
//  Created by Tim on 05.09.2023.
//

import UIKit

final class PhotoView: UIViewController {
    
    private let url: URL
    private let item: MediaFile
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(contentsOfFile: url.path)
        return imageView
    }()
    
    init(with url: URL, item: MediaFile) {
        self.url = url
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(imageView)
        view.backgroundColor = .black
        let isVertival = view.bounds.width < view.bounds.height
        NSLayoutConstraint.activate([
            isVertival ? imageView.widthAnchor.constraint(equalTo: view.widthAnchor)
            : imageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem = infoButton
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if view.bounds.width < view.bounds.height {
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = false
        } else {
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = false
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
    }
    
    @objc private func infoButtonPressed() {
        guard let name = item.name,
              let lastChanges = item.lastChanges
        else {
            return
        }
        let info =  """
                    Name: \(name)
                    Last changes: \(lastChanges.formatted(date: .numeric, time: .shortened))
                    """
        let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}
