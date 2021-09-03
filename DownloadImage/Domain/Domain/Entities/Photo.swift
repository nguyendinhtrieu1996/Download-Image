//
//  Photo.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import UIKit

public struct Photo {
    public let id: Int
    public let author: String
    public let width: CGFloat
    public let height: CGFloat
    public let url: String
    public let urlString: String
    
    public init(id: Int,
                author: String,
                width: CGFloat,
                height: CGFloat,
                url: String,
                urlString: String) {
        
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.url = url
        self.urlString = urlString
    }
}
