//
//  GrayscaleViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/22.
//

import UIKit

class GrayscaleViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image1 = grayscale(image: imageView1.image!, filterName: "CIPhotoEffectNoir")
        let image2 = grayscale(image: imageView1.image!, filterName: "CIPhotoEffectMono")
        let image3 = grayscale(image: imageView1.image!, filterName: "CIPhotoEffectTonal")
        
        imageView1.image = image1
        imageView2.image = image2
        imageView3.image = image3
        
        let image4 = convertToGrayScale(image: imageView1.image!)
        imageView4.image = image4
    }
}

