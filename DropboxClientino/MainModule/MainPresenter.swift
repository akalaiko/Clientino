//
//  MainPresenter.swift
//  DropboxClientino
//
//  Created by Tim on 03.09.2023.
//

import AdSupport
import AppTrackingTransparency
import AVFoundation
import SwiftyDropbox
import UIKit

protocol PresenterProtocol: AnyObject {
    func loadFiles(page: Int)
    func openFull(file: MediaFile)
}

class MainPresenter {
    
    weak var view: (UIViewController & ViewProtocol)?
    private let mediaNetworkManager: MediaNetwork?
    private var itemsFromDropbox: [MediaFile]?
    
    init(view: UIViewController & ViewProtocol) {
        self.view = view
        mediaNetworkManager = MediaNetworkManager()
    }
    
    private func auth() {
        mediaNetworkManager?.auth(on: view) { [weak self] in
            self?.loadFiles(page: 0)
        }
    }
    
    private func fetchMediaFiles() {
        mediaNetworkManager?.fetchMediaFiles { [weak self] mediaFiles in
            guard let self else { return }
            itemsFromDropbox = mediaFiles.sorted()
            loadFiles(page: 0)
        }
    }
    
    private func createViewModels(for items: [MediaFile]?) {
        guard let items = items else { return }
        var models = [MainViewModel]()
        let dispatchGroup = DispatchGroup()
        
        for item in items {
            dispatchGroup.enter()
            mediaNetworkManager?.getThumbnail(for: item) { thumbnail in
                let model = MainViewModel(file: item, preview: thumbnail)
                models.append(model)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            self?.updateView(with: models)
        }
    }
    
    private func updateView(with items: [MainViewModel]?) {
        view?.display(newItems: items)
    }
    
    private func createDetailedViewForMedia(with url: URL, file: MediaFile, for fileType: FileType) {
        let controller: UIViewController
        switch fileType {
        case .image:
            let photoController = PhotoView(with: url, item: file)
            controller = photoController
        case .video:
            let videoController = VideoView(with: url, item: file)
            controller = videoController
        case .notMedia:
            return
        }
        view?.displayDetails(with: controller)
    }
}

extension MainPresenter: PresenterProtocol {
    func loadFiles(page: Int) {
        guard let itemsFromDropbox else {
            if DropboxClientsManager.authorizedClient != nil {
                fetchMediaFiles()
            } else {
                auth()
            }
            return
        }
        let firstIndex = page * Constants.itemsOnPage
        let lastIndexOnPage = firstIndex + Constants.itemsOnPage - 1
        let lastIndexOfArray = itemsFromDropbox.count - 1
        let lastIndex = lastIndexOnPage < lastIndexOfArray ? lastIndexOnPage : lastIndexOfArray
        guard firstIndex <= lastIndex else {
            view?.nothingToLoad()
            return
        }
        createViewModels(for: Array(itemsFromDropbox[firstIndex...lastIndex]))
    }
    
    func openFull(file: MediaFile) {
        guard let url = file.localURLOfCachedFile,
              let pathForDownload = file.path,
              let fileType = file.type else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            createDetailedViewForMedia(with: url, file: file, for: fileType)
        } else {
            mediaNetworkManager?.downloadFileForDetailedView(url: url, path: pathForDownload) { [weak self] in
                self?.createDetailedViewForMedia(with: url, file: file, for: fileType)
            }
        }
    }
}
