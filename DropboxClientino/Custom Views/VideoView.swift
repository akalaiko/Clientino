//
//  VideoView.swift
//  DropboxClientino
//
//  Created by Tim on 05.09.2023.
//

import AVKit

final class VideoView: AVPlayerViewController {
    
    private let url: URL
    private let item: MediaFile
    
    init(with url: URL, item: MediaFile) {
        self.url = url
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.player = AVPlayer(url: url)
        player?.play()
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem = infoButton
        navigationItem.rightBarButtonItem?.isEnabled = true
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
