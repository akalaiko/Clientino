//
//  MainView.swift
//  DropboxClientino
//
//  Created by Tim on 03.09.2023.
//

import UIKit

protocol ViewProtocol: AnyObject {
    func display(newItems: [MainViewModel]?)
    func displayDetails(with controller: UIViewController)
    func nothingToLoad()
}

final class MainView: UIViewController {
    
    var presenter: PresenterProtocol?
    var items: [MainViewModel]?
    
    private var currentPage = 0
    private var isLoading = false
    private var isInitialLoad = true
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .medium
        return indicator
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.padding
        layout.minimumLineSpacing = Constants.padding
        layout.sectionInset = UIEdgeInsets(top: Constants.padding, left: Constants.padding, bottom: Constants.padding, right: Constants.padding)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TileCollectionViewCell.self, forCellWithReuseIdentifier: "TileCell")
        collectionView.scrollsToTop = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func loadView() {
        super.loadView()
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if items == nil {
            presenter?.loadFiles(page: currentPage)
        }
    }
    
    private func initialSetup() {
        title = "Dropbox"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        activityIndicator.startAnimating()
    }
    
    @objc private func refreshData() {
        currentPage = 0
        items = nil
        presenter?.loadFiles(page: currentPage)
    }
}

extension MainView: ViewProtocol {
    public func display(newItems: [MainViewModel]?) {
        guard let newItems else { return }
        if items == nil {
            self.items = newItems
        } else {
            self.items?.append(contentsOf: newItems)
        }
        collectionView.reloadData()
        isLoading = false
        activityIndicator.stopAnimating()
        collectionView.refreshControl?.endRefreshing()
    }
    
    public func displayDetails(with controller: UIViewController) {
        activityIndicator.startAnimating()
        navigationController?.pushViewController(controller, animated: true)
        activityIndicator.stopAnimating()
    }
    
    public func nothingToLoad() {
        activityIndicator.stopAnimating()
    }
}

extension MainView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as? TileCollectionViewCell,
              let item = items?[indexPath.row],
              let image = item.preview,
              let name = item.file.name,
              let type = item.file.type
        else {
            return UICollectionViewCell()
        }
        cell.config(image: image, name: name, isVideo: type == .video)
        return cell
    }
}

extension MainView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        let numberOfItemsInRow: CGFloat = screenWidth > screenHeight ? Constants.itemsInHorizontal : Constants.itemsInVertical
        
        let padding = (numberOfItemsInRow + 1) * Constants.padding // sum of paddings on the left, right and inbetween items in a row
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / numberOfItemsInRow
        return CGSize(width: itemWidth, height: itemWidth + Constants.lpadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = items?[indexPath.row].file else { return }
        presenter?.openFull(file: file)
    }
}

extension MainView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLoading && scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            guard !isInitialLoad else {
                isInitialLoad.toggle()
                return
            }
            isLoading = true
            activityIndicator.startAnimating()
            currentPage += 1
            presenter?.loadFiles(page: currentPage)
        }
    }
}
