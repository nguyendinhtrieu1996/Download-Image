//
//  KeyStoreProtocol.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import Foundation

protocol KeyValueStoreProtocol {
    @discardableResult
    func setString(_ value: String?, forKey key: String) -> Bool
    @discardableResult
    func getStringValue(for key: String) -> String?
    
    @discardableResult
    func set<T:Encodable>(_ value: T?, forKey key: String) -> Bool
    @discardableResult
    func getCodableObj<T: Decodable>(forKey key: String) -> T?
    
    @discardableResult
    func removeValue(forKey key: String) -> Bool
}
