//
//  ViewModelTypeProtocol.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import UIKit

protocol ViewModelTypeProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
