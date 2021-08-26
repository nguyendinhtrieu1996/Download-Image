//
//  UserConfigurationUseCase.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

typealias LoadUserConfigCompletion = (Result<UserConfiguration, Error>) -> Void
typealias SaveUserConfigCompletion = (Result<Void, Error>) -> Void

protocol UserConfigurationUseCase {
    func loadConfig(with completion: LoadUserConfigCompletion)
    func saveConfig(_ config: UserConfiguration, completion: SaveUserConfigCompletion)
}

final class DefaultUserConfigurationUseCase: UserConfigurationUseCase {
    
    private var userConfigRespository: UserConfigurtionRespository
    
    init(userConfigRespository: UserConfigurtionRespository) {
        self.userConfigRespository = userConfigRespository
    }
    
    func loadConfig(with completion: (Result<UserConfiguration, Error>) -> Void) {
        self.userConfigRespository.loadConfig(with: completion)
    }
    
    func saveConfig(_ config: UserConfiguration, completion: (Result<Void, Error>) -> Void) {
        self.userConfigRespository.saveConfig(config, completion: completion)
    }
    
}
