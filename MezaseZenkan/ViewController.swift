//
//  ViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/20.
//

import UIKit

class ViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    @IBOutlet weak var colViewRaces: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var highRaces: [Race] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colViewRaces.dataSource = self
        colViewRaces.delegate = self
        
        let fileLocation = Bundle.main.url(forResource: "SampleData", withExtension: "json")
        
        do {
            // 4. 해당 위치의 파일을 Data로 초기화하기
            let data = try Data(contentsOf: fileLocation!)
            let array = try JSONDecoder().decode(Array<Race>.self, from: data)
            highRaces = array.filter { ($0.grade == "G1" || $0.grade == "G2" || $0.grade == "G3") && $0.displayOrder > 1 }
            highRaces.sort {
                ($0.grade, $0.displayOrder) < ($1.grade, $1.displayOrder)
            }
            print(highRaces)
        } catch {
            print(error)
        }
    }
    
    @IBAction func pageControlChanged(_ sender: Any) {
        
    }
    
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        highRaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RaceCell", for: indexPath) as? RaceCell else {
            return UICollectionViewCell()
        }
        cell.update(race: highRaces[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 3
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 5
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
}

class RaceCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBanner: UIImageView!
    
    func update(race: Race) {
        lblTitle.text = race.name
        imgBanner.image = UIImage(named: "images/\(race.bannerURL).png")
    }
}
