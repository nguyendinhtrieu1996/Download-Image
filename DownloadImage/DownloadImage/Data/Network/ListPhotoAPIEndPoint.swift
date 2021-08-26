//
//  ListPhotoAPIEndPoint.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

struct ListPhotoAPIEndPoint {
    
    static func getListPhoto(with listPhotoRequestDTO: ListPhotoRequestDTO) -> Endpoint<[PhotoResponseDTO]> {
        return Endpoint(path: "list/",
                        method: .get,
                        queryParametersEncodable: listPhotoRequestDTO)
    }
    
}
