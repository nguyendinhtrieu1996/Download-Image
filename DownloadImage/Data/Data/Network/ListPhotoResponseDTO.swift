//
//  ListPhotoResponseDTO.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import UIKit
import Domain

struct PhotoResponseDTO: Decodable {
    let id: Int
    let author: String
    let width: CGFloat
    let height: CGFloat
    let url: String
    let urlString: String
}

extension PhotoResponseDTO {
    
    func toDomain() -> Photo {
        return .init(id: id,
                     author: author,
                     width: width,
                     height: height,
                     url: url,
                     urlString: urlString)
    }
}
