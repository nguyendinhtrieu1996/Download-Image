//
//  DefaultListPhotoRespository.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation
import Domain
import Infrastructure

final class DefaultListPhotoRespository {
    private var dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
}

// MARK: - ListPhotoRespository

extension DefaultListPhotoRespository: ListPhotoRespository {
    
    func fetchListPhoto(query: PhotoQuery, completion: @escaping FetchListPhotoCompletion) {
        let requestDTO = ListPhotoRequestDTO(page: query.page, limit: query.limit)
        let endPoint = ListPhotoAPIEndPoint.getListPhoto(with: requestDTO)
        
        self.dataTransferService.request(with: endPoint) { result in
            switch result {
            case .success(let responseDTO):
                let photos = responseDTO.map { $0.toDomain() }
                completion(.success(photos))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
}
