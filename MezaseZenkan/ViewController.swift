//
//  ViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/20.
//

import UIKit

class ViewController: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    var tagStartInfo: [Int] = []
    var pageVC: PageViewController?
    var currentSegIndex = 0
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var segRaceGrade: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func pageControlChanged(_ sender: Any) {
        
    }
    
    @IBAction func segRaceGradeChanged(_ sender: UISegmentedControl) {
        let selectedSegIndex = sender.selectedSegmentIndex
        let targetPageIndex = tagStartInfo[selectedSegIndex]
        
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
    
    func didDataLoadCompleted(_ controller: PageViewController, pageTotalCount: [Int], tagStartInfo: [Int]) {
        for i in 0...2 {
            segRaceGrade.setTitle("G\(i + 1) (\(pageTotalCount[i]))", forSegmentAt: i)
        }
        print(#function, tagStartInfo)
        self.tagStartInfo = tagStartInfo
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
