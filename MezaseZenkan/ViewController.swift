//
//  ViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/20.
//

import UIKit

class ViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    var tagStartInfo: [String: Int] = [:]
    var pageTotalCount: [Int] = []
    var pageVC: PageViewController?
    var currentSegIndex = 0
    var finishedRaceCount: [String: Int]? {
        didSet {
            print("afdsfd:", finishedRaceCount)
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var segRaceGrade: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func pageControlChanged(_ sender: Any) {
        
    }
    
    @IBAction func segRaceGradeChanged(_ sender: UISegmentedControl) {
        let selectedSegIndex = sender.selectedSegmentIndex
        let grade = selectedSegIndex == 0 ? "G1" : selectedSegIndex == 1 ? "G2" : "G3"
        let targetPageIndex = tagStartInfo[grade] ?? 0
        
        if let pageVC = pageVC {
            if selectedSegIndex == currentSegIndex {
                currentSegIndex = selectedSegIndex
                return
            }
            let direction:UIPageViewController.NavigationDirection = selectedSegIndex > currentSegIndex ? .forward : .reverse
            pageVC.setViewControllers([pageVC.vcArray[targetPageIndex]], direction: direction, animated: true, completion: nil)
            
        }
        currentSegIndex = selectedSegIndex
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ContainerToPageVCSegue" {
            pageVC = segue.destination as? PageViewController
            pageVC?.containerDelegate = self
        }
    }
}

extension ViewController: PageViewDelegate {
    
    func didChangedFinishedRaceCount(_ controller: PageViewController, finishedRaceCount: [String : Int]) {
        for i in 0...2 {
            let raceGradeText: String = "G\(i + 1)"
            segRaceGrade.setTitle("\(raceGradeText) (\(finishedRaceCount[raceGradeText] ?? 0)/\(pageTotalCount[i]))", forSegmentAt: i)
        }
    }
    
    func didDataLoadCompleted(_ controller: PageViewController, pageTotalCount: [Int], tagStartInfo: [String: Int]) {
        for i in 0...2 {
            let raceGradeText: String = "G\(i + 1)"
            segRaceGrade.setTitle("\(raceGradeText) (-/\(pageTotalCount[i]))", forSegmentAt: i)
        }
        
        self.tagStartInfo = tagStartInfo
        self.pageTotalCount = pageTotalCount
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
