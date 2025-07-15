//
//  PageViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/21.
//

import UIKit

protocol PageViewDelegate: AnyObject {
  func didPageMoved(_ controller: PageViewController, currentGrade: String, currentTag: Int)
  func didChangedFinishedRaceCount(_ controller: PageViewController)
}

class PageViewController: UIPageViewController, UIGestureRecognizerDelegate {
  
  weak var containerDelegate: PageViewDelegate?
  
  var raceViewModel: RaceViewModel!
  var raceStateViewModel: RaceStateViewModel!
  var filterViewModel: FilterViewModel!
  
  var currentMusume: Musume!
  
  var currentLongPressedCell: RaceCell?
  
  lazy var vcArray: [UIViewController] = {
    let array = (0...raceViewModel.totalTagsCount - 1).map { index in
      return self.vcInstance(tag: index)
    }
    return array
  }()
  
  private func vcInstance(tag: Int) -> UIViewController{
    let collectionVC: UICollectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubRaceCollectionVC") as! UICollectionViewController
    collectionVC.collectionView.tag = tag
    
    collectionVC.collectionView.register(UINib(nibName: "RaceCell", bundle: nil), forCellWithReuseIdentifier: "SubRaceCell")
    collectionVC.collectionView.delegate = self
    collectionVC.collectionView.dataSource = self
    
    setupLongGestureRecognizerOnCollection(collectionVC: collectionVC)
    return collectionVC
  }
  
  // long press 이벤트 부여
  private func setupLongGestureRecognizerOnCollection(collectionVC: UICollectionViewController) {
    
    let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
    longPressedGesture.minimumPressDuration = 0.35
    longPressedGesture.delegate = self
    longPressedGesture.delaysTouchesBegan = true
    collectionVC.collectionView.addGestureRecognizer(longPressedGesture)
  }
  
  // long press 이벤트 액션
  @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    let location = gestureRecognizer.location(in: gestureRecognizer.view)
    let collectionView = gestureRecognizer.view as! UICollectionView
    
    if gestureRecognizer.state == .began {
      
      if let indexPath = collectionView.indexPathForItem(at: location) {
        print("Long press at item began: \(indexPath.row)")
        
        // animation
        UIView.animate(withDuration: 0.2) {
          if let cell = collectionView.cellForItem(at: indexPath) as? RaceCell {
            self.currentLongPressedCell = cell
            cell.transform = .init(scaleX: 0.95, y: 0.95)
          }
        }
      }
    } else if gestureRecognizer.state == .ended {
      print("lt ended")
      if let indexPath = collectionView.indexPathForItem(at: location) {
        print("Long press at item end: \(indexPath.row)")
        
        // animation
        UIView.animate(withDuration: 0.2) {
          if let cell = self.currentLongPressedCell  {
            cell.transform = .init(scaleX: 1, y: 1)
            
            if cell == collectionView.cellForItem(at: indexPath) as? RaceCell,
               let url = URL(string: "https://gamewith.jp/uma-musume/article/show/\(cell.currentRace.gamewithPostid)") {
              UIApplication.shared.open(url, options: [:])
            }
          }
        }
      }
    } else {
      return
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateFinishedRaceCount()
    
    // 딜리게이트, 데이터소스 연결
    self.dataSource = self
    self.delegate = self
    
    // 첫 번째 페이지를 기본 페이지로 설정
    if let firstVC = vcArray.first {
      setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
    }
    
    TrackingTransparencyPermissionRequest()
    
  }
  
  private func updateFinishedRaceCount() {
    if let containerDelegate = containerDelegate {
      containerDelegate.didChangedFinishedRaceCount(self)
    }
  }
  
  func reload() {
    vcArray.forEach({ vc in
      (vc as! UICollectionViewController).collectionView.reloadData()
    })
  }
  
}

extension PageViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    raceViewModel.getViewCountBy(tag: collectionView.tag)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubRaceCell", for: indexPath) as? RaceCell else {
      return UICollectionViewCell()
    }
    
    let race = raceViewModel.getRaceBy(tag: collectionView.tag, row: indexPath.row)
    
    let isFinished: Bool = raceStateViewModel.getFinishedBy(musumeName: currentMusume.name, raceName: race.name)
    let refinedConditions = filterViewModel.getRefinedConditionsBy(race: race)
    cell.update(race: race, isFinished: isFinished, filterConditions: refinedConditions)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let targetRace = raceViewModel.getRaceBy(tag: collectionView.tag, row: indexPath.row)
    raceStateViewModel.toggleFinishResult(musumeName: currentMusume.name, raceName: targetRace.name)
    
    collectionView.reloadItems(at: [indexPath])
    
    updateFinishedRaceCount()
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
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
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
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
  
  
  // 페이지 이동 시
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let currentVC = pageViewController.viewControllers?[0] as! UICollectionViewController
    let currentCVTag = currentVC.collectionView.tag
    // print("currentVC.collectionView.tag:", currentVC.collectionView.tag, raceViewModel.getGradeBy(tag: currentCVTag))
    
    if containerDelegate != nil {
      containerDelegate?.didPageMoved(self, currentGrade: raceViewModel.getGradeBy(tag: currentCVTag), currentTag: currentCVTag)
    }
  }
  
}

class RaceCell: UICollectionViewCell {
  @IBOutlet weak var imgBanner: UIImageView!
  @IBOutlet weak var lblInfo: UILabel!
  @IBOutlet weak var lblTitle: UILabel!
  
  @IBOutlet weak var cnstSubviewWidth: NSLayoutConstraint!
  @IBOutlet weak var cnstSubviewHeight: NSLayoutConstraint!
  
  var currentRace: Race!
  
  func update(race: Race, isFinished: Bool, filterConditions: Set<FilterCondition>) {
    currentRace = race
    
    let image: UIImage = {
      guard let bannerImage = UIImage(named: "images/\(race.bannerURL).png"),
            UserDefaults.standard.bool(forKey: .cfgShowHighResBanner) else {
        return raceToBanner(race: race)
      }
      
      return bannerImage
    }()
    
    if isFinished {
      imgBanner.image = image
      imgBanner.alpha = 1
    } else {
      imgBanner.image = convertToGrayScale(image: image)
      imgBanner.alpha = 0.5
    }
    
    // ==== section: style ====
    
    lblInfo.attributedText = attributedRaceStringMaker(from: race, filterConditions: filterConditions)
    lblTitle.text = race.name
    
    cnstSubviewWidth.constant = self.frame.width
    cnstSubviewHeight.constant = self.frame.height
    let newSubviewHeight = cnstSubviewHeight.constant
    
    // original height: 132
    if newSubviewHeight > 132.9 {
      let fontScale = (newSubviewHeight / 132)
      lblTitle.font = UIFont.systemFont(ofSize: fontScale * 17, weight: .bold)
      lblTitle.minimumScaleFactor = 0.7
      lblInfo.font = UIFont.systemFont(ofSize: fontScale * 0.85 * 14)
      
    }
  }
  
  private func setComponentsPosition() { }
}

