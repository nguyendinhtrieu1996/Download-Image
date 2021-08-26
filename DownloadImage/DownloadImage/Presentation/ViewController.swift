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
        
        TNWebImageDownloader.shared.downloadImage(with: url,
                                                  options: .scaleDownLargeImage,
                                                  context: nil,
                                                  progressBlock: nil)
        { image, data, error, finish in
            DispatchQueue.main.async {
                print("Out put width = \(image?.size.width ?? -1) height = \(image?.size.height ?? -1)")
                
                #if DEBUG
                let imageSize = Double(data!.count)
                NSLog("Out put SIZE OF IMAGE: %f Mb", imageSize/1024/1024)
                #endif // DEBUG
                
                self.imageView.image = image
            }
        }
        
    }
    
}

