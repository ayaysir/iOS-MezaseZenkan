//
//  ViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/20.
//

import UIKit

class ViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func pageControlChanged(_ sender: Any) {
        
    }
    
    
}

//class RaceCell: UICollectionViewCell {
//
//    @IBOutlet weak var imgBanner: UIImageView!
//    @IBOutlet weak var lblInfo: UILabel!
//
//    func update(race: Race) {
//        imgBanner.image = UIImage(named: "images/\(race.bannerURL).png")
//        let infoText = "\(race.period) / \(race.month)月 \(race.half) / \(race.grade)\n\(race.terrain) / \(race.length)m(\(race.lengthType)) / \(race.direction)"
//        lblInfo.text = infoText
//    }
//}
