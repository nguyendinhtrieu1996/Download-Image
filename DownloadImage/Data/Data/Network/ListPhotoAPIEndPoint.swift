//
//  ListPhotoAPIEndPoint.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation
import Infrastructure

struct ListPhotoAPIEndPoint {
    
    static func getListPhoto(with queryDTO: PhotoQueryDTO) -> Endpoint<[PhotoResponseDTO]> {
        return Endpoint(path: "list/",
                        method: .get,
                        queryParametersEncodable: queryDTO)
    }
    
}
