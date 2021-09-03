//
//  DefaultUserConfigurationResponsitory.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import Foundation
import Domain

final class DefaultUserConfigurationResponsitory {
    var userConfigurationStorage: UserConfigurationStorage
    
    init(with userConfigurationStorage: UserConfigurationStorage) {
        self.userConfigurationStorage = userConfigurationStorage
    }
}

// MARK: - UserConfigurtionRespository

extension DefaultUserConfigurationResponsitory: UserConfigurtionRespository {
    
    func loadConfig(with completion: (Result<UserConfiguration, Error>) -> Void) {
        self.userConfigurationStorage.loadConfig(with: completion)
    }
    
    func saveConfig(_ config: UserConfiguration, completion: (Result<Void, Error>) -> Void) {
        self.userConfigurationStorage.saveConfig(config, completion: completion)
    }
}
