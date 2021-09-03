//
//  FetchListPhotoUseCase.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import UIKit

public typealias FetchListPhotoCompletion = (Result<[Photo], Error>) -> Void

public protocol FetchListPhotoUseCase {
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion)
}

final class DefaultFetchListPhotoUseCase: FetchListPhotoUseCase {
    
    private var listPhotoRespository: ListPhotoRespository
    
    init(listPhotoRespository: ListPhotoRespository) {
        self.listPhotoRespository = listPhotoRespository
    }
    
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion) {
        self.listPhotoRespository.fetchListPhoto(query: query, completion: completion)
    }
    
}
