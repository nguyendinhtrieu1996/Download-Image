//
//  UserConfiguration.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

public enum PhotoListMode: Int {
    case regular = 0
    case compact = 1
}

public struct UserConfiguration {
    public let photoListMode: PhotoListMode
    
    public init(photoListMode: PhotoListMode) {
        self.photoListMode = photoListMode
    }
    
}
