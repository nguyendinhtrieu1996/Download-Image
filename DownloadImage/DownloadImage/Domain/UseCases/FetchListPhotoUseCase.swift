//
//  FetchListPhotoUseCase.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import UIKit

typealias FetchListPhotoCompletion = (Result<[Photo], Error>) -> Void
typealias FetchImageCompletion = (Result<UIImage, Error>) -> Void

protocol FetchListPhotoUseCase {
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion)
    func fetchImage(from urlString: String, completion: @escaping FetchImageCompletion)
}

final class DefaultFetchListPhotoUseCase: FetchListPhotoUseCase {
    
    private var listPhotoRespository: ListPhotoRespository
    
    init(listPhotoRespository: ListPhotoRespository) {
        self.listPhotoRespository = listPhotoRespository
    }
    
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion) {
        self.listPhotoRespository.fetchListPhoto(query: query, completion: completion)
    }
    
    func fetchImage(from urlString: String, completion: @escaping FetchImageCompletion) {
        self.listPhotoRespository.fetchImage(from: urlString, completion: completion)
    }
    
}
