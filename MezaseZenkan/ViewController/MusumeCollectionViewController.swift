//
//  MusumeCollectionViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/27.
//

import UIKit

protocol MusumeCollectionVCDelegate: AnyObject {
  func didChangedMusume(_ controller: MusumeCollectionViewController, musume: Musume)
}

fileprivate let reuseIdentifier = "MusumeCell"

class MusumeCollectionViewController: UICollectionViewController {
  weak var delegate: MusumeCollectionVCDelegate?
  
  var musumeViewModel: MusumeViewModel!
  var raceStateViewModel: RaceStateViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    TrackingTransparencyPermissionRequest()
  }
  
  // MARK: UICollectionViewDataSource
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return musumeViewModel.totalCount
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MusumeCell else {
      return UICollectionViewCell()
    }
    
    // Configure the cell
    let musume = musumeViewModel.getMusumeBy(index: indexPath.row)
    let finishedRaceCount = raceStateViewModel?.getFinishedRaceNamesBy(musumeName: musume.name).count ?? 0
    let isCurrentSelected = musumeViewModel.currentMusume == musume
    cell.update(musume: musume, finishedRaceCount: finishedRaceCount, isCurrent: isCurrentSelected)
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let musume = musumeViewModel.getMusumeBy(index: indexPath.row)

    if let delegate = delegate {
      delegate.didChangedMusume(self, musume: musume)
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PlusHeader", for: indexPath)
      return headerView
      
    default:
      return UICollectionReusableView()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "CreateMusume":
      let vc = segue.destination as! CreateMusumeTableViewController
      vc.delegate = self
      vc.musumeViewModel = musumeViewModel
    default:
      break
    }
  }
}

extension MusumeCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }
  
  // 사이즈 결정
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.frame.width
    let itemsPerRow: CGFloat = 6
    let widthPadding = 10 * (itemsPerRow + 1)
    let cellWidth = (width - widthPadding) / itemsPerRow
    
    // print(#function, cellWidth)
    return CGSize(width: cellWidth, height: cellWidth * 1.15)
  }
}

extension MusumeCollectionViewController: CreateMusumeTVCDelegate {
  func didAddedMusume(_ controller: CreateMusumeTableViewController, addedMusume: Musume) {
    collectionView.reloadData()
  }
}

class MusumeCell: UICollectionViewCell {
  @IBOutlet weak var imgViewProfile: UIImageView!
  @IBOutlet weak var lblMusumeName: UILabel!
  @IBOutlet weak var lblRaceStatus: UILabel!
  
  func update(musume: Musume, finishedRaceCount: Int, isCurrent: Bool = false) {
    imgViewProfile.layer.cornerRadius = imgViewProfile.frame.width * 0
    imgViewProfile.image = MusumeHelper.getImage(of: musume)
    
    lblMusumeName.text = musume.name
    lblRaceStatus.text = "\(finishedRaceCount)"
    
    self.backgroundColor = isCurrent ? .systemPink.withAlphaComponent(0.5) : .clear
  }
}
