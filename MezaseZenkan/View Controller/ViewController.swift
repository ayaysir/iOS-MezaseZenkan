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
    
//    var currentMusume: Musume!
    
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
