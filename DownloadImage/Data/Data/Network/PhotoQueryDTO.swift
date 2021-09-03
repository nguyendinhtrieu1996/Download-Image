//
//  PhotoQueryDTO.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation
import Domain

struct PhotoQueryDTO: Encodable {
    let page: Int
    let limit: Int
}

// MARK: Transform

extension PhotoQuery {
    
    func toDTO() -> PhotoQueryDTO {
        return PhotoQueryDTO(page: self.page,
                             limit: self.limit)
    }
}
