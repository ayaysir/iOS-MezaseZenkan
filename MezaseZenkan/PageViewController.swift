//
//  PageViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/21.
//

import UIKit

protocol PageViewDelegate: AnyObject {
    func didPageMoved(_ controller: PageViewController, currentGrade: String)
    func didDataLoadCompleted(_ controller: PageViewController, pageTotalCount: [Int], tagStartInfo: [Int])
}

class PageViewController: UIPageViewController {
    
    weak var containerDelegate: PageViewDelegate?
    
    var g1Races: [Race] = []
    var g2Races: [Race] = []
    var g3Races: [Race] = []
    var raceChunks: [[Race]] = []
    var tagRaceInfo: [String] = []
    
    var sampleCurrentMusume: String = "ハルウララ"
    var sampleMusumeAndFinishedRace: [String: [String: Bool]] = [
        "ハルウララ": ["ホープフルステークス": true, "安田記念": true, "札幌記念": true, "武蔵野ステークス": true]
    ]
    var sampleFinishedRace: [String: Bool] = ["ホープフルステークス": true, "安田記念": true, "札幌記念": true, "武蔵野ステークス": true]
    
    lazy var vcArray: [UIViewController] = {
        let array = (0...raceChunks.count - 1).map { index in
            return self.vcInstance(tag: index)
        }
        print("vcAraray", array)
        return array
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
            
            g1Races = array.filter { ($0.grade == "G1") && $0.displayOrder > 0 }
            g1Races.sort {
                ($0.grade, $0.displayOrder) < ($1.grade, $1.displayOrder)
            }
            
            g2Races = array.filter { ($0.grade == "G2") && $0.displayOrder > 0 }
            g2Races.sort {
                ($0.grade, $0.displayOrder) < ($1.grade, $1.displayOrder)
            }
            
            g3Races = array.filter { ($0.grade == "G3") && $0.displayOrder > 0 }
            g3Races.sort {
                ($0.grade, $0.displayOrder) < ($1.grade, $1.displayOrder)
            }
            
            print(g1Races.count, g2Races.count, g3Races.count)
            
            raceChunks = g1Races.chunked(into: 15) + g2Races.chunked(into: 15) + g3Races.chunked(into: 15)
            let g1TagCount = ceil(Double(g1Races.count) / 15)
            let g2TagCount = ceil(Double(g2Races.count) / 15)
            let g3TagCount = ceil(Double(g3Races.count) / 15)
            tagRaceInfo.append(contentsOf: repeatElement("G1", count: Int(g1TagCount)))
            tagRaceInfo.append(contentsOf: repeatElement("G2", count: Int(g2TagCount)))
            tagRaceInfo.append(contentsOf: repeatElement("G3", count: Int(g3TagCount)))
            print(g1TagCount, g2TagCount, g3TagCount, tagRaceInfo)
            
            // 각 클리어 레이스 카운트
            
            
            if(containerDelegate != nil) {
                containerDelegate?.didDataLoadCompleted(self, pageTotalCount: [g1Races.count, g2Races.count, g3Races.count], tagStartInfo: [0, Int(g1TagCount), Int(g1TagCount + g2TagCount)])
            }
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
        raceChunks[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubRaceCell", for: indexPath) as? RaceCell else {
            return UICollectionViewCell()
        }
        
        let race = raceChunks[collectionView.tag][indexPath.row]
        let isFinished: Bool = sampleMusumeAndFinishedRace[sampleCurrentMusume]![race.name] ?? false
        cell.update(race: raceChunks[collectionView.tag][indexPath.row], isFinished: isFinished)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let targetRace = raceChunks[collectionView.tag][indexPath.row]
        sampleMusumeAndFinishedRace[sampleCurrentMusume]![targetRace.name] = !(sampleFinishedRace[targetRace.name] ?? false)
        collectionView.reloadItems(at: [indexPath])
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
        
        return CGSize(width: cellWidth, height: cellHeight)    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
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
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentVC = pageViewController.viewControllers?[0] as! UICollectionViewController
        print("currentVC.collectionView.tag:", currentVC.collectionView.tag, tagRaceInfo[currentVC.collectionView.tag])
        
        if containerDelegate != nil {
            containerDelegate?.didPageMoved(self, currentGrade: tagRaceInfo[currentVC.collectionView.tag])
        }
    }
    
}

class RaceCell: UICollectionViewCell {

    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    func update(race: Race, isFinished: Bool) {
        let image = UIImage(named: "images/\(race.bannerURL).png")
        if let image = image {
            if isFinished {
                imgBanner.image = image
                imgBanner.alpha = 1
            } else {
                imgBanner.image = convertToGrayScale(image: image)
                imgBanner.alpha = 0.5
            }
        }

        let infoText = "\(race.period) / \(race.month)月\(race.half) / \(race.grade)\n\(race.terrain) / \(race.length)m(\(race.lengthType)) / \(race.direction)"
        lblInfo.text = infoText
        lblTitle.text = race.name
    }
}

