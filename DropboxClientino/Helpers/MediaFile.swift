//
//  MediaFile.swift
//  DropboxClientino
//
//  Created by Tim on 03.09.2023.
//

import UIKit
import UniformTypeIdentifiers

struct MediaFile {
    let id: String?
    let name: String?
    let path: String?
    let lastChanges: Date?

    var localURLOfCachedFile: URL? {
        guard let name else { return nil }
        let localFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let localFileURL = URL(fileURLWithPath: localFilePath).appendingPathComponent(name)
        return localFileURL
    }
    var localURLOfPreviewFile: URL? {
        guard let name else { return nil }
        let localFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let localFileURL = URL(fileURLWithPath: localFilePath).appendingPathComponent("preview_" + name)
        return localFileURL
    }
    var type: FileType? {
        guard let localURLOfCachedFile else { return nil }
        guard let uti = UTType(filenameExtension: localURLOfCachedFile.pathExtension) else { return nil }
        if uti.conforms(to: .image) {
            return .image
        } else if uti.conforms(to: .movie) {
            return .video
        } else {
            return .notMedia
        }
    }
}

extension MediaFile: Comparable {
    static func < (lhs: MediaFile, rhs: MediaFile) -> Bool {
        guard let firstID = lhs.id,
              let secondID = rhs.id
        else {
            return false
        }
        return firstID < secondID
    }
}

