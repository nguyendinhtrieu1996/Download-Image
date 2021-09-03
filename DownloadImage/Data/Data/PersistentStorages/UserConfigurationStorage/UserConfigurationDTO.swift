//
//  UserConfigurationDTO.swift
//  Data
//
//  Created by Trieu Nguyen on 03/09/2021.
//

import UIKit
import Domain

struct UserConfigurationDTO: Codable {
    let photoListMode: PhotoListMode
    
    enum CodingKeys: String, CodingKey {
        case photoListMode = "photoListMode"
    }
    
    public init(photoListMode: PhotoListMode) {
        self.photoListMode = photoListMode
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
         
        let photoListModeValue = try values.decode(Int.self, forKey: .photoListMode)
        photoListMode = PhotoListMode(rawValue: photoListModeValue) ?? .regular
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.photoListMode.rawValue, forKey: .photoListMode)
    }
}

// MARK: Transform

extension UserConfigurationDTO {
    
    func toDomain() -> UserConfiguration {
        return UserConfiguration(photoListMode: self.photoListMode)
    }
}


extension UserConfiguration {
    
    func toDTO() -> UserConfigurationDTO {
        return UserConfigurationDTO(photoListMode: self.photoListMode)
    }
}
