//
//  NetworkManager.swift
//  DropboxClientino
//
//  Created by Tim on 03.09.2023.
//

import UIKit
import SwiftyDropbox

protocol MediaNetwork: AnyObject {
    func auth(on controller: UIViewController?, completion: @escaping () -> Void)
    func fetchMediaFiles( completion: @escaping ([MediaFile]) -> Void)
    func getThumbnail(for mediaFile: MediaFile, completion: @escaping (UIImage?) -> Void)
    func downloadFileForDetailedView(url: URL, path: String, completion: @escaping () -> ())
}

final class MediaNetworkManager: MediaNetwork {
    
    private let tokenRefresher: TokenRefreshProtocol = DropboxRefreshManager()
    
    func auth(on controller: UIViewController?, completion: @escaping () -> Void) {
        tokenRefresher.refreshToken { _ in
            completion()
        }
    }
    
    func getThumbnail(for mediaFile: MediaFile, completion: @escaping (UIImage?) -> Void) {
        guard let url = mediaFile.localURLOfPreviewFile else { return }
        if let image = UIImage(contentsOfFile: url.path) {
            completion(image)
            return
        }
        
        guard let photoPath = mediaFile.path else { return }
        if let client = DropboxClientsManager.authorizedClient {
            client.files.getThumbnail(path: photoPath, format: .png, size: .w256h256).response { response, error in
                if let (_, data) = response {
                    if let image = UIImage(data: data) {
                        try? data.write(to: url)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                } else if let error = error {
                    print("Failed to fetch image: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    func downloadFileForDetailedView(url: URL, path: String, completion: @escaping () -> ()) {
        DropboxClientsManager.authorizedClient?.files.download(
            path: path,
            destination: { (_, _) -> URL in return url })
        .response { response, error in
            if response != nil {
                completion()
            } else if let error {
                print("Ошибка загрузки файла: \(error)")
            }
        }
    }
    
    func fetchMediaFiles( completion: @escaping ([MediaFile]) -> Void) {
        
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        client.files.listFolder(path: "").response { response, error in
            if let result = response {
                let mediaFiles = result.entries.compactMap { entry -> MediaFile? in
                    if let fileMetadata = entry as? Files.FileMetadata {
                        let name = fileMetadata.name
                        let id = fileMetadata.id
                        let imagePath = fileMetadata.pathDisplay
                        let lastChanges = fileMetadata.clientModified
                        let mediaFile = MediaFile(id: id, name: name, path: imagePath, lastChanges: lastChanges)
                        return mediaFile
                    }
                    return nil
                }
                completion(mediaFiles)
            } else if let error {
                print("Error fetching media files: \(error)")
                DropboxClientsManager.unlinkClients()
                completion([])
            }
        }
    }
}
