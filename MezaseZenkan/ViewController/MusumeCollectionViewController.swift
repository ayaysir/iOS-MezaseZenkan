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
    let isCurrentSelected = musumeViewModel.currentMusume.name == musume.name
    cell.update(musume: musume, finishedRaceCount: finishedRaceCount, isCurrent: isCurrentSelected)
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectMusume(of: indexPath.row)
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
  
  override func collectionView(
    _ collectionView: UICollectionView,
    contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
    point: CGPoint
  ) -> UIContextMenuConfiguration? {
    UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [unowned self] _ in
      guard let firstIndexPath = indexPaths.first else {
        return nil
      }
      
      let selectedMusume = musumeViewModel.getMusumeBy(index: firstIndexPath.row)
      let isCurrentMusume = selectedMusume == musumeViewModel.currentMusume
      let deleteActionAttributes: UIMenuElement.Attributes = (isCurrentMusume ? .disabled : .destructive)
      let deleteAction = UIAction(
        title: "삭제",
        image: UIImage(systemName: "trash"),
        attributes: deleteActionAttributes
      ) { action in
        print("삭제: \(firstIndexPath)")
        // 삭제 창 띄우기
        self.showAlertDelete(of: selectedMusume)
      }
      
      let updateAction = UIAction(
        title: "업데이트",
        image: UIImage(systemName: "play")
      ) { [unowned self] action in
        performSegue(withIdentifier: "UpdateMusume", sender: selectedMusume)
      }
      
      let infoAction = UIAction(title: "정보 보기", image: UIImage(systemName: "info.circle")) { [unowned self] action in
        // print("정보: \(firstIndexPath)")
        selectMusume(of: firstIndexPath.row)
      }
      
      return UIMenu(title: "", children: [infoAction, updateAction, deleteAction])
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "CreateMusume":
      let vc = segue.destination as! CreateMusumeTableViewController
      vc.delegate = self
      vc.musumeViewModel = musumeViewModel
      vc.mode = .create
    case "UpdateMusume":
      let vc = segue.destination as! CreateMusumeTableViewController
      vc.delegate = self
      vc.musumeViewModel = musumeViewModel
      vc.mode = .update
      vc.musumeToUpdate = sender as? Musume
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
  func didUpdatedMusume(_ controller: CreateMusumeTableViewController, updatedMusume: Musume) {
    // - 현재 캐릭터가 아니면 컬렉션 뷰만 리로드
    // - 현재 캐릭터를 업데이트했다면
    //   - 2. 사진이 바뀌었다면 사진 업데이트
    
    if musumeViewModel.currentMusume.name == updatedMusume.name {
      delegate?.didChangedMusume(self, musume: updatedMusume)
    }
    
    collectionView.reloadData()
  }
  
  func didAddedMusume(_ controller: CreateMusumeTableViewController, addedMusume: Musume) {
    collectionView.reloadData()
  }
}

extension MusumeCollectionViewController {
  /// 캐릭터 선택 후 시트를 닫고 정보 표시
  func selectMusume(of index: Int) {
    let musume = musumeViewModel.getMusumeBy(index: index)

    if let delegate {
      delegate.didChangedMusume(self, musume: musume)
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  /// 삭제 여부 묻는 얼럿 표시
  func showAlertDelete(of musume: Musume) {
    let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
      guard let self else { return }
      removeInfo(of: musume)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    let alert = UIAlertController(
      title: "삭제",
      message: "\(musume.name)의 모든 정보를 삭제하시겠습니까? 이 명령은 되돌릴 수 없습니다.",
      preferredStyle: .alert
    )
    alert.addAction(cancelAction)
    alert.addAction(deleteAction)
    present(alert, animated: true)
  }
  
  /// Musume, RaceStates 정보 삭제 명령 호출
  func removeInfo(of musume: Musume) {
    musumeViewModel.removeMusume([musume])
    raceStateViewModel.removeAllStates(of: musume.name)
    deleteFile(named: "\(musume.name).png")
    collectionView.reloadData()
  }
}

class MusumeCell: UICollectionViewCell {
  @IBOutlet weak var imgViewProfile: UIImageView!
  @IBOutlet weak var lblMusumeName: UILabel!
  @IBOutlet weak var lblRaceStatus: UILabel!
  @IBOutlet weak var lblGameRegion: UILabel!
  
  func update(musume: Musume, finishedRaceCount: Int, isCurrent: Bool = false) {
    imgViewProfile.layer.cornerRadius = imgViewProfile.frame.width * 0.5
    imgViewProfile.image = MusumeHelper.getImage(of: musume)
    
    lblMusumeName.text = musume.name
    lblRaceStatus.text = "\(finishedRaceCount)"
    
    self.backgroundColor = isCurrent ? .systemPink.withAlphaComponent(0.5) : .clear
    
    let region = MusumeHelper.extractGameAppRegion(from: musume.comment)
    lblGameRegion.clipsToBounds = true
    lblGameRegion.layer.cornerRadius = 3.5
    lblGameRegion.text = switch region {
    case .ja:
      "🇯🇵ja"
    case .ko:
      "🇰🇷ko"
    }
  }
}
