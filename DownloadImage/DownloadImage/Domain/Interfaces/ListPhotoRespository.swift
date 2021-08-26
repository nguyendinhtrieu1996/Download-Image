//
//  ListPhotoRespository.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

protocol ListPhotoRespository {
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion)
    func fetchImage(from urlString: String, completion: @escaping FetchImageCompletion)
}
