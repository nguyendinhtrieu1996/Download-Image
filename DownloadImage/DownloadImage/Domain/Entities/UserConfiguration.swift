//
//  UserConfiguration.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

enum PhotoListMode: Int {
    case regular = 0
    case compact = 1
}

struct UserConfiguration {
    let photoListMode: PhotoListMode
}
