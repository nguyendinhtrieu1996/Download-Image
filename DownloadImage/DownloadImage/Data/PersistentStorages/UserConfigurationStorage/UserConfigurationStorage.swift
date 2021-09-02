//
//  UserConfigurationStorage.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import Foundation

protocol UserConfigurationStorage {
    func loadConfig(with completion: (Result<UserConfiguration, Error>) -> Void)
    func saveConfig(_ config: UserConfiguration, completion: (Result<Void, Error>) -> Void)
}
