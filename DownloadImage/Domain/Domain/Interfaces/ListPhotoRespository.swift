//
//  ListPhotoRespository.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

public protocol ListPhotoRespository {
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion)
}
