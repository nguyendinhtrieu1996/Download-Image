//
//  PhotoQuery.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import Foundation

public struct PhotoQuery {
    public let page: Int
    public let limit: Int
    
    public init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
    }
}
