//
//  MainViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/20.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController {
  private var bannerView: GADBannerView!
  
  let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  
  // 여기서 raceViewModel을 생성하면 PageVC, RotationVC에서 사용
  var raceViewModel: RaceViewModel!
  let raceStateViewModel = RaceStateViewModel()
  let musumeViewModel = MusumeViewModel()
  let filterViewModel = FilterViewModel()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    // print(musumeViewModel.currentMusume.comment)
    let region: GameAppRegion = MusumeHelper.extractGameAppRegion(from: musumeViewModel.currentMusume.comment)
    raceViewModel = RaceViewModel(region: region)
    filterViewModel.racesRegion = region
  }
  
  var pageVC: PageViewController!
  var currentSegIndex = 0
  var preservedPageIndex = 0
  
  var filterConditions: Set<String> = ["G1"]
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var segRaceGrade: UISegmentedControl!
  @IBOutlet weak var lblMusumeName: UILabel!
  @IBOutlet weak var imgViewMusume: UIImageView!
  @IBOutlet weak var lblFinishStatus: UILabel!
  @IBOutlet weak var colViewFilter: UICollectionView!
  @IBOutlet weak var btnRotationView: UIButton!
  @IBOutlet weak var imgViewLogo: UIImageView!
  @IBOutlet weak var btnHelp: UIButton!
  @IBOutlet weak var viewBannerAds: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Localization
    btnRotationView.setTitle("loc.btn_rotation_view".localized, for: .normal)
    
    imgViewMusume.layer.cornerRadius = imgViewMusume.frame.width * 0.5
    btnRotationView.layer.cornerRadius = 10
    imgViewLogo.layer.cornerRadius = imgViewLogo.frame.width * 0.5
    btnHelp.layer.cornerRadius = 10
    btnHelp.layer.borderWidth = 1
    btnHelp.layer.borderColor = UIColor.systemGray3.cgColor
    
    TrackingTransparencyPermissionRequest()
    
    // 광고 - 이 페이지밖에 없음
    // if PRODUCT_MODE && SHOW_AD
    if SHOW_AD {
      bannerView = setupBannerAds(adUnitID: AD_UNIT_ID)
      bannerView.delegate = self
    }
    
    colViewFilter.delegate = self
    colViewFilter.dataSource = self
    
    updateViewStatus()
    initImageTouch()
    
    renderPageControl()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    checkAppFirstrunOrUpdateStatus {
      
    } updated: {
      let msg1_01_1 = """
            以下が更新されました。 (Ver 1.01.1)
             • 川崎、船橋、盛岡のレース場追加に伴うレース情報追加とフィルター追加
             • レースバナー画像を高画質バナーに置き換える機能を追加（タイトルのヘルプボタンを押すと対応する機能があります。）
             • バグ修正と機能改善
            
            このメッセージは現在のバージョンでは再表示されません。
            """
      simpleAlert(self, message: msg1_01_1, title: "バージョンの更新", handler: nil)
    } nothingChanged: {
      
    }
  }
  
  private func renderPageControl(currentPage: Int = 0) {
    pageControl.numberOfPages = raceViewModel.totalTagsCount
    pageControl.currentPage = currentPage
    preservedPageIndex = currentPage
  }
  
  private func initImageTouch() {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTouch(gesture:)))
    imgViewMusume.isUserInteractionEnabled = true
    imgViewMusume.addGestureRecognizer(gesture)
  }
  
  @objc func handleImageTouch(gesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: "SelectMusumeSegue", sender: nil)
  }
  
  @IBAction func pageControlChanged(_ sender: UIPageControl) {
    // print(#function, sender.currentPage)
    
    let targetPageIndex = sender.currentPage
    
    if let pageVC = pageVC {
      if preservedPageIndex == targetPageIndex {
        return
      }
      
      let direction: UIPageViewController.NavigationDirection = preservedPageIndex < targetPageIndex ? .forward : .reverse
      pageVC.setViewControllers([pageVC.vcArray[targetPageIndex]], direction: direction, animated: true, completion: nil)
      
      moveSegment(currentGrade: raceViewModel.getGradeBy(tag: targetPageIndex))
    }
    preservedPageIndex = targetPageIndex
  }
  
  @IBAction func segRaceGradeChanged(_ sender: UISegmentedControl) {
    let selectedSegIndex = sender.selectedSegmentIndex
    let grade = selectedSegIndex == 0 ? "G1" : selectedSegIndex == 1 ? "G2" : "G3"
    let targetPageIndex = raceViewModel.tagStartInfo[grade] ?? 0
    
    if let pageVC = pageVC {
      if selectedSegIndex == currentSegIndex {
        currentSegIndex = selectedSegIndex
        return
      }
      let direction: UIPageViewController.NavigationDirection = currentSegIndex < selectedSegIndex ? .forward : .reverse
      pageVC.setViewControllers([pageVC.vcArray[targetPageIndex]], direction: direction, animated: true, completion: nil)
      pageControl.currentPage = targetPageIndex
    }
    currentSegIndex = selectedSegIndex
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "ContainerToPageVCSegue":
      pageVC = segue.destination as? PageViewController
      pageVC.containerDelegate = self
      pageVC.raceViewModel = raceViewModel
      pageVC.raceStateViewModel = raceStateViewModel
      pageVC.filterViewModel = filterViewModel
      pageVC.currentMusume = musumeViewModel.currentMusume
    case "SelectMusumeSegue":
      let musumeVC = segue.destination as? MusumeCollectionViewController
      musumeVC?.delegate = self
      musumeVC?.raceStateViewModel = raceStateViewModel
      musumeVC?.musumeViewModel = musumeViewModel
    case "RotationSegue":
      let rotationVC = segue.destination as? RotationViewController
      rotationVC?.raceViewModel = raceViewModel
      rotationVC?.raceStateViewModel = raceStateViewModel
      rotationVC?.musumeViewModel = musumeViewModel
    case "WebPageSegue":
      let webVC = segue.destination as? WebViewController
      webVC?.delegate = self
    default:
      break
    }
  }
  
  private func updateViewStatus() {
    if let currentMusume = musumeViewModel.currentMusume {
      
      lblMusumeName.text = currentMusume.name
      imgViewMusume.image = MusumeHelper.getImage(of: currentMusume)
      
      let finishedRaceNameList = raceStateViewModel.getFinishedRaceNamesBy(musumeName: currentMusume.name)
      let finishedRaceCount = raceViewModel.getFinishedCountBy(raceNameList: finishedRaceNameList)
      
      for i in 0...2 {
        let raceGradeText: String = "G\(i + 1)"
        let finishedRaceCount: Any? = finishedRaceCount[raceGradeText]
        segRaceGrade.setTitle("\(raceGradeText) (\(finishedRaceCount ?? "-")/\(raceViewModel.gradeCountArr[i]))", forSegmentAt: i)
      }
      
      lblFinishStatus.text = "\(raceStateViewModel.getTotalFinishedRaceCountBy(musumeName: musumeViewModel.currentMusume.name) ?? 0) / \(raceViewModel.totalRaceCount)"
    }
  }
}

extension MainViewController: PageViewDelegate {
  func didChangedFinishedRaceCount(_ controller: PageViewController) {
    updateViewStatus()
  }
  
  func didPageMoved(_ controller: PageViewController, currentGrade: String, currentTag: Int) {
    
    moveSegment(currentGrade: currentGrade)
    
    // 페이지컨트롤 조작
    renderPageControl(currentPage: currentTag)
  }
  
  func moveSegment(currentGrade: String) {
    switch currentGrade {
    case "G1":
      segRaceGrade.selectedSegmentIndex = 0
      currentSegIndex = 0
    case "G2":
      segRaceGrade.selectedSegmentIndex = 1
      currentSegIndex = 1
    case "G3":
      segRaceGrade.selectedSegmentIndex = 2
      currentSegIndex = 2
    default:
      return
    }
  }
}

extension MainViewController: MusumeCollectionVCDelegate {
  func didChangedMusume(_ controller: MusumeCollectionViewController, musume: Musume) {
    let region = MusumeHelper.extractGameAppRegion(from: musume.comment)
    raceViewModel.changeRaceData(to: region)
    filterViewModel.racesRegion = region
    colViewFilter.reloadData()
    
    musumeViewModel.currentMusume = musume
    pageVC.currentMusume = musume
    pageVC.raceViewModel = raceViewModel
    pageVC.reload()
    updateViewStatus()
  }
}

extension MainViewController: WebVCDelegate {
  func didChangedBannerRes(_ controller: WebViewController) {
    pageVC.reload()
  }
}

// MARK: - Filter

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    FilterHelper.displayMenuCount
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
      return UICollectionViewCell()
    }
    
    if indexPath.row < FilterHelper.displayMenuCount {
      guard let menu = FilterHelper.getFilterMenuBy(row: indexPath.row) else {
        fatalError("AddDirtRace: filterMenus: \(FilterHelper.filterMenus.sorted { $0.value.displayOrder < $1.value.displayOrder })")
      }
      cell.update(filterMenu: menu, conditions: filterViewModel.currentFilterConditions)
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let menu = FilterHelper.getFilterMenuBy(row: indexPath.row)!
    
    if menu.filterCondition == .reset {
      filterViewModel.reset()
      collectionView.reloadData()
      pageVC.reload()
      return
    }
    
    filterViewModel.toggleCurrentCondition(condition: menu.filterCondition)
    pageVC.reload()
    // print("currentFilterS:", filterViewModel.currentFilterConditions)
    
    if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
      if cell.backgroundColor == .clear {
        return
      }
      
      collectionView.reloadItems(at: [indexPath])
    }
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let colViewWidth: CGFloat = collectionView.frame.width
    
    let itemsPerRow = FilterHelper.getSectionCountOfIndex(row: indexPath.row) ?? 4
    let leftInset: CGFloat = {
      switch itemsPerRow {
      case 1:
        return 0
      case 2:
        return 3
      default:
        return 5
      }
    }()
    
    let widthPadding: CGFloat = leftInset * CGFloat(itemsPerRow + 1)
    let cellWidth: CGFloat = (colViewWidth - widthPadding) / CGFloat(itemsPerRow)
    
    let height: CGFloat = 30
    return CGSize(width: cellWidth, height: height)
  }
}

class FilterCell: UICollectionViewCell {
  @IBOutlet weak var lblMenuName: UILabel!
  
  var deactivatedColor = RGB255(red: 230, green: 230, blue: 230, alpha: 0.7).uiColor
  var filterMenu: FilterMenu!
  
  func update(filterMenu: FilterMenu, conditions: Set<FilterCondition>) {
    
    self.filterMenu = filterMenu
    lblMenuName.text = filterMenu.searchName
    lblMenuName.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
    self.layer.cornerRadius = 8
    
    if filterMenu.searchName == "" {
      self.backgroundColor = .clear
    } else {
      self.backgroundColor = deactivatedColor
    }
    
    self.backgroundColor = conditions.contains(filterMenu.filterCondition) ? RGB255(red: 240, green: 212, blue: 103).uiColor : deactivatedColor
    
  }
  
  private func highlightCell(isOn: Bool) { }
}

extension MainViewController: GADBannerViewDelegate {
  
  private func setupBannerAds(adUnitID: String = "ca-app-pub-3940256099942544/2934735716") -> GADBannerView {
    
    viewBannerAds.layoutIfNeeded()
    let bannerWidth = viewBannerAds.frame.width
    // print("bw:", bannerWidth)
    let adSize = GADAdSizeFromCGSize(CGSize(width: bannerWidth, height: viewBannerAds.frame.height))
    let bannerView = GADBannerView(adSize: adSize)
    
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    viewBannerAds.addSubview(bannerView)
    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = self
    
    let request = GADRequest()
    bannerView.load(request)
    
    return bannerView
  }
}
