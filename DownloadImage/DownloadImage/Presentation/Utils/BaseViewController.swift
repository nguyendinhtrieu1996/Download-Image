//
//  BaseViewController.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 02/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
    }

}
