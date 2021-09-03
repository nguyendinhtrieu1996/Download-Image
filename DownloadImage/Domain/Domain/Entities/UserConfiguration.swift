//
//  UserConfiguration.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

public enum PhotoListMode: Int {
    case regular = 0
    case compact = 1
}

public struct UserConfiguration: Codable {
    let photoListMode: PhotoListMode
    
    enum CodingKeys: String, CodingKey {
        case photoListMode = "photoListMode"
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
