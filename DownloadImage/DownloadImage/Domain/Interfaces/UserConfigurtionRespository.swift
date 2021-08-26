//
//  UserConfigurtionRespository.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

protocol UserConfigurtionRespository {
    
    func loadConfig(with completion: LoadUserConfigCompletion)
    
    func saveConfig(_ config: UserConfiguration, completion: SaveUserConfigCompletion)
    
}
