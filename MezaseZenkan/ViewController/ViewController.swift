//
//  ViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/20.
//

import UIKit

class ViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    let raceViewModel = RaceViewModel()
    let raceStateViewModel = RaceStateViewModel()
    let musumeViewModel = MusumeViewModel()
    let filterViewModel = FilterViewModel()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgViewMusume.layer.cornerRadius = imgViewMusume.frame.width * 0.5
        btnRotationView.layer.cornerRadius = 10
        imgViewLogo.layer.cornerRadius = imgViewLogo.frame.width * 0.5
        
        colViewFilter.delegate = self
        colViewFilter.dataSource = self
        
        updateViewStatus()
        initImageTouch()
        
        renderPageControl()
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
        print(#function, sender.currentPage)
        
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
        default:
            break
        }
    }
    
    private func updateViewStatus() {
        
        if let currentMusume = musumeViewModel.currentMusume {
            
            lblMusumeName.text = currentMusume.name
            imgViewMusume.image = UIImage(named: "images/\(currentMusume.imgProfile)")
            
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

extension ViewController: PageViewDelegate {
    
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

extension ViewController: MusumeCollectionVCDelegate {
    
    func didChangedMusume(_ controller: MusumeCollectionViewController, musume: Musume) {
        musumeViewModel.currentMusume = musume
        pageVC.currentMusume = musume
        pageVC.reload()
        updateViewStatus()
    }
}

// MARK: - Filter

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        FilterHelper.displayMenuCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row < FilterHelper.displayMenuCount {
            
            let menu = FilterHelper.getFilterMenuBy(row: indexPath.row)!
            
            cell.update(filterMenu: menu)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let menu = FilterHelper.getFilterMenuBy(row: indexPath.row)!
        
        if menu.filterCondition == .reset {
            filterViewModel.reset()
            pageVC.reload()
            return
        }
        
        filterViewModel.toggleCurrentCondition(condition: menu.filterCondition)
        pageVC.reload()
        print("currentFilterS:", filterViewModel.currentFilterConditions)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
            
            if cell.backgroundColor == .clear {
                return
            }
            
            cell.isOn = !cell.isOn
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        print("highlight")
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        print("unhighlight")
//    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
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
    var isOn: Bool = false {
        didSet {
            self.backgroundColor = isOn ? RGB255(red: 240, green: 212, blue: 103).uiColor : deactivatedColor
        }
    }
    
    func update(filterMenu: FilterMenu) {
        
        self.filterMenu = filterMenu
        lblMenuName.text = filterMenu.searchName
        lblMenuName.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        self.layer.cornerRadius = 8
        
        if filterMenu.searchName == "" {
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = deactivatedColor
        }
    }
    
}
