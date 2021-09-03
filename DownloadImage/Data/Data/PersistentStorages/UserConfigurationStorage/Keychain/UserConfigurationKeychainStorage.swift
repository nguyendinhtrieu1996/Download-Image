//
//  UserConfigurationKeychainStorage.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import UIKit
import Domain

enum UserConfigurationStorageError: Error {
    case saveError
}

final class UserConfigurationKeychainStorage {
    var keyValueStore: KeyValueStoreProtocol
    
    private enum KeyStore {
        static let userConfig = "kUserConfig"
    }
    
    init(with keyValueStore: KeyValueStoreProtocol) {
        self.keyValueStore = keyValueStore
    }
}

// MARK: - UserConfigurationStorage

extension UserConfigurationKeychainStorage: UserConfigurationStorage {
    
    func loadConfig(with completion: (Result<UserConfiguration, Error>) -> Void) {
        let userConfigDTO: UserConfigurationDTO? = self.keyValueStore.getCodableObj(forKey: KeyStore.userConfig)
        
        if let userConfigDTO = userConfigDTO {
            completion(.success(userConfigDTO.toDomain()))
        } else {
            completion(.failure(UserConfigurationStorageError.saveError))
        }
    }
    
    func saveConfig(_ config: UserConfiguration, completion: (Result<Void, Error>) -> Void) {
        self.keyValueStore.set(config.toDTO(), forKey: KeyStore.userConfig)
    }
}
