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
    
    var filterConditions: Set<String> = ["G1"]
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var segRaceGrade: UISegmentedControl!
    @IBOutlet weak var lblMusumeName: UILabel!
    @IBOutlet weak var imgViewMusume: UIImageView!
    @IBOutlet weak var lblFinishStatus: UILabel!
    @IBOutlet weak var colViewFilter: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgViewMusume.layer.cornerRadius = imgViewMusume.frame.width * 0.5
        
        colViewFilter.delegate = self
        colViewFilter.dataSource = self
        
        updateViewStatus()
        initImageTouch()
    }
    
    private func initImageTouch() {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTouch(gesture:)))
        imgViewMusume.isUserInteractionEnabled = true
        imgViewMusume.addGestureRecognizer(gesture)
    }
    
    @objc func handleImageTouch(gesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "SelectMusumeSegue", sender: nil)
    }
    
    @IBAction func pageControlChanged(_ sender: Any) {
        
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
            let direction: UIPageViewController.NavigationDirection = selectedSegIndex > currentSegIndex ? .forward : .reverse
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
    
//    func didChangedMusumeName(_ controller: PageViewController, musumeName: String) {
//        lblMusumeName.text = musumeName
//    }
    
    func didChangedFinishedRaceCount(_ controller: PageViewController) {
        updateViewStatus()
    }
    
    func didPageMoved(_ controller: PageViewController, currentGrade: String) {
        print("!!!!", currentGrade)
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
            cell.update(filterMenu: FilterHelper.getFilterMenuBy(row: indexPath.row)!)
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
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let width = collectionView.frame.width
//        let height = collectionView.frame.height
//        let itemsPerRow: CGFloat = 3
//        let widthPadding = 10 * (itemsPerRow + 1)
//        let itemsPerColumn: CGFloat = 5
//        let heightPadding = 10 * (itemsPerColumn + 1)
//        let cellWidth = (width - widthPadding) / itemsPerRow
//        let cellHeight = (height - heightPadding) / itemsPerColumn
        print(collectionView.frame.width)
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
        
        let height: CGFloat = 35
        return CGSize(width: cellWidth, height: height)
    }
}

class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var lblMenuName: UILabel!
    
    var filterMenu: FilterMenu!
    
    func update(filterMenu: FilterMenu) {
        
        self.filterMenu = filterMenu
        lblMenuName.text = filterMenu.searchName
    }
}
