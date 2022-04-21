//
//  PageViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/21.
//

import UIKit

class PageViewController: UIPageViewController {
    
    var highRaces: [Race] = []
    
    lazy var vcArray: [UIViewController] = {
        return [self.vcInstance(tag: 1),
                self.vcInstance(tag: 2),
                self.vcInstance(tag: 3)]
    }()
    
    private func vcInstance(tag: Int) -> UIViewController{
        let collectionVC: UICollectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubRaceCollectionVC") as! UICollectionViewController
        collectionVC.collectionView.tag = tag
        
        collectionVC.collectionView.register(UINib(nibName: "RaceCell", bundle: nil), forCellWithReuseIdentifier: "SubRaceCell")
        collectionVC.collectionView.delegate = self
        collectionVC.collectionView.dataSource = self
        return collectionVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileLocation = Bundle.main.url(forResource: "SampleData", withExtension: "json")
        
        do {
            //
            let data = try Data(contentsOf: fileLocation!)
            let array = try JSONDecoder().decode(Array<Race>.self, from: data)
            highRaces = array.filter { ($0.grade == "G1" || $0.grade == "G2" || $0.grade == "G3") && $0.displayOrder > 0 }
            highRaces.sort {
                ($0.grade, $0.displayOrder) < ($1.grade, $1.displayOrder)
            }
            print(highRaces)
        } catch {
            print(error)
        }

        // 딜리게이트, 데이터소스 연결
        self.dataSource = self
        self.delegate = self
        
        // 첫 번째 페이지를 기본 페이지로 설정
        if let firstVC = vcArray.first {
            
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension PageViewController: UICollectionViewDataSource, UICollectionViewDelegate  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return 15
        case 2:
            return 7
        case 3:
            return 9
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubRaceCell", for: indexPath) as? RaceCell else {
            return UICollectionViewCell()
        }
        
        cell.update(race: highRaces[indexPath.row])
        return cell
    }
    
}

extension PageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 3
        let widthPadding = 10 * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 5
        let heightPadding = 10 * (itemsPerColumn + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        print(cellWidth, cellHeight)
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 배열에서 현재 페이지의 컨트롤러를 찾아서 해당 인덱스를 현재 인덱스로 기록
            guard let vcIndex = vcArray.firstIndex(of: viewController) else { return nil }
            
            // 이전 페이지 인덱스
            let prevIndex = vcIndex - 1
            
            // 인덱스가 0 이상이라면 그냥 놔둠
            guard prevIndex >= 0 else {
                return nil
                
                // 무한반복 시 - 1페이지에서 마지막 페이지로 가야함
                // return vcArray.last
            }
            
            // 인덱스는 vcArray.count 이상이 될 수 없음
            guard vcArray.count > prevIndex else { return nil }
            
            return vcArray[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = vcArray.firstIndex(of: viewController) else { return nil }
           
           // 다음 페이지 인덱스
           let nextIndex = vcIndex + 1
           
           guard nextIndex < vcArray.count else {
               return nil
               
               // 무한반복 시 - 마지막 페이지에서 1 페이지로 가야함
               // return vcArray.first
           }
           
           guard vcArray.count > nextIndex else { return nil }
           
           return vcArray[nextIndex]
    }
    
}

class RaceCell: UICollectionViewCell {

    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!

    func update(race: Race) {
        imgBanner.image = UIImage(named: "images/\(race.bannerURL).png")
        let infoText = "\(race.period) / \(race.month)月 \(race.half) / \(race.grade)\n\(race.terrain) / \(race.length)m(\(race.lengthType)) / \(race.direction)"
        lblInfo.text = infoText
    }
}

