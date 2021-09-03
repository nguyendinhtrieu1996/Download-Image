//
//  ListPhotoRequestDTO.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

public struct ListPhotoRequestDTO: Codable {
    let page: Int
    let limit: Int
}
