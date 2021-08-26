//
//  ImageDownloader.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 25/06/2021.
//

import UIKit

typealias ImageDownloaderCompletion = (Result<UIImage, Error>) -> Void

protocol ImageDownloader {
    func getImage(from urlString: String, completion: ImageDownloaderCompletion)
}
