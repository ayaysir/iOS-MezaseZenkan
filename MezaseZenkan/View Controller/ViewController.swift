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
    
    var currentMusumeName: String = "ハルウララ"
    
    var pageVC: PageViewController!
    var currentSegIndex = 0
    var finishedRaceCount: [String: Int]? {
        didSet {
            
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var segRaceGrade: UISegmentedControl!
    @IBOutlet weak var lblMusumeName: UILabel!
    @IBOutlet weak var imgViewMusume: UIImageView!
    @IBOutlet weak var lblFinishStatus: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgViewMusume.layer.cornerRadius = imgViewMusume.frame.width * 0.5
        
        lblMusumeName.text = currentMusumeName
        updateViewStatus()
        
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
            pageVC.currentMusumeName = "ハルウララ"
        case "SelectMusumeSegue":
            let musumeVC = segue.destination as? MusumeCollectionViewController
            musumeVC?.delegate = self
            musumeVC?.raceStateViewModel = raceStateViewModel
        default:
            break
        }
    }
    
    private func updateViewStatus() {
        
        let finishedRaceNameList = raceStateViewModel.getFinishedRaceNamesBy(musumeName: currentMusumeName)
        let finishedRaceCount = raceViewModel.getFinishedCountBy(raceNameList: finishedRaceNameList)
        
        for i in 0...2 {
            let raceGradeText: String = "G\(i + 1)"
            let finishedRaceCount: Any? = finishedRaceCount[raceGradeText]
            segRaceGrade.setTitle("\(raceGradeText) (\(finishedRaceCount ?? "-")/\(raceViewModel.gradeCountArr[i]))", forSegmentAt: i)
        }
        
        lblFinishStatus.text = "\(raceStateViewModel.getTotalFinishedRaceCountBy(musumeName: currentMusumeName) ?? 0) / \(raceViewModel.totalRaceCount)"
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
    
    func didChangedMusume(_ controller: MusumeCollectionViewController, musumeName: String) {
        self.currentMusumeName = musumeName
        pageVC.currentMusumeName = musumeName
        pageVC.reload()
        lblMusumeName.text = musumeName
        updateViewStatus()
    }
    
    
}
