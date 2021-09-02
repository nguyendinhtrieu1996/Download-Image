//
//  ViewController.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 24/06/2021.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/world.topo.bathy.200407.3x5400x2700.png")!
        
        TNImageManager.shared.loadImage(with: url,
                                        options: .continueInBackground,
                                        cacheType: .all)
        { expectSize, receivedSize, url in
            let progress = Double(receivedSize) / Double(expectSize);
            print("Download progress: \(progress * 100) %")
        } completion: { image, error, cacheType, url in
            print("Download Compleye with error: \(String(describing: error?.localizedDescription))")
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }

    }
    
}

