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
  
  enum SelectMode {
    case normal, multipleSelect
  }
  private var selectedMusumeIndexes: Set<Int> = []
  private var selectMode: SelectMode = .normal {
    didSet {
      didSetSelectMode()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    TrackingTransparencyPermissionRequest()
  }
  
  // MARK: - UICollectionViewDataSource
  
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
    let isMultiSelected = selectedMusumeIndexes.contains(indexPath.row)
    cell.update(
      musume: musume,
      finishedRaceCount: finishedRaceCount,
      isCurrent: isCurrentSelected,
      selectMode: selectMode,
      isMultiSelected: isMultiSelected
    )
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch selectMode {
    case .normal:
      selectMusume(of: indexPath.row)
    case .multipleSelect:
      guard musumeViewModel.currentMusume != musumeViewModel.getMusumeBy(index: indexPath.row) else {
        return
      }
      
      if selectedMusumeIndexes.contains(indexPath.row) {
        selectedMusumeIndexes.remove(indexPath.row)
      } else {
        selectedMusumeIndexes.insert(indexPath.row)
      }
      
      collectionView.reloadItems(at: [indexPath])
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PlusHeader", for: indexPath) as? MusumeCollectionHeaderCell else {
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
      }
      
      headerView.delegate = self
      headerView.btnAddNewMusume.setTitle(
        "loc.btn_add_new_musume".localized,
        for: .normal
      )
      headerView.btnCancel.setTitle(
        "loc.cancel".localized,
        for: .normal
      )
      
      if selectMode == .multipleSelect {
        headerView.btnModeSelect_Delete.setTitle(
          "loc.mc_btn_delete_all".localized,
          for: .normal
        )
      } else {
        headerView.btnModeSelect_Delete.setTitle(
          "loc.mc_btn_multiple_selection".localized,
          for: .normal
        )
      }
      
      return headerView
      
    default:
      return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
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
        title: "loc.delete".localized,
        image: UIImage(systemName: "trash"),
        attributes: deleteActionAttributes
      ) { action in
        print("삭제: \(firstIndexPath)")
        // 삭제 창 띄우기
        self.showAlertDelete(of: selectedMusume)
      }
      
      let updateAction = UIAction(
        title: "loc.update".localized,
        image: UIImage(systemName: "play")
      ) { [unowned self] action in
        performSegue(withIdentifier: "UpdateMusume", sender: selectedMusume)
      }
      
      let infoAction = UIAction(
        title: "loc.view_info".localized,
        image: UIImage(systemName: "info.circle")
      ) { [unowned self] action in
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
    // - 현재 캐릭터를 업데이트했다면: 사진이 바뀌었다면 사진 업데이트
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
  func didSetSelectMode() {
    guard let headerView = collectionView.supplementaryView(
      forElementKind: UICollectionView.elementKindSectionHeader,
      at: IndexPath(row: 0, section: 0)
    ) as? MusumeCollectionHeaderCell else {
      print("headerView not found")
      return
    }
    
    collectionView.reloadData()
    
    switch selectMode {
    case .normal:
      headerView.btnCancel.isHidden = true
      headerView.btnModeSelect_Delete.setTitle(
        "loc.mc_btn_multiple_selection".localized,
        for: .normal
      )
      headerView.btnModeSelect_Delete.setTitleColor(nil, for: .normal)
    case .multipleSelect:
      headerView.btnCancel.isHidden = false
      headerView.btnModeSelect_Delete.setTitle(
        "loc.mc_btn_delete_all".localized,
        for: .normal
      )
      headerView.btnModeSelect_Delete.setTitleColor(.systemRed, for: .normal)
    }
  }
  
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
    simpleDestructiveYesAndNo(
      self,
      message: "loc.confirm_delete_one".localizedFormat(musume.name),
      title: "loc.delete".localized) { [weak self] _ in
        guard let self else { return }
        removeInfo(of: musume)
      }
  }
  
  /// Musume, RaceStates 정보 삭제 명령 호출
  func removeInfo(of musume: Musume) {
    raceStateViewModel.removeAllStates(of: musume.name)
    deleteFile(named: "\(musume.name).png")
    musumeViewModel.removeMusume([musume])
    collectionView.reloadData()
  }
  
  func removeSelectedInfo() {
    selectedMusumeIndexes.forEach { index in
      let name = musumeViewModel.getMusumeBy(index: index).name
      raceStateViewModel.removeAllStates(of: name)
      deleteFile(named: "\(name).png")
    }
    
    musumeViewModel.removeMusume(by: selectedMusumeIndexes)
    collectionView.reloadData()
    selectMode = .normal
  }
}

extension MusumeCollectionViewController: MusumeColletionHeaderDelegate {
  func didTriggeredBtnActCancel() {
    if selectMode == .multipleSelect {
      selectMode = .normal
      selectedMusumeIndexes = []
    }
  }
  
  func didTriggeredBtnActMultiSelect_Delete() {
    if selectMode == .normal {
      selectMode = .multipleSelect
    } else {
      // 삭제 작업
      guard !selectedMusumeIndexes.isEmpty else {
        simpleAlert(self, message: "loc.alert_no_musume".localized)
        return
      }
      
      simpleDestructiveYesAndNo(
        self,
        message: "loc.confirm_delete_multi".localizedFormat(selectedMusumeIndexes.count),
        title: "loc.delete".localized) { [weak self] _ in
          guard let self else { return }
          removeSelectedInfo()
        }
    }
  }
}

class MusumeCell: UICollectionViewCell {
  @IBOutlet weak var imgViewProfile: UIImageView!
  @IBOutlet weak var lblMusumeName: UILabel!
  @IBOutlet weak var lblRaceStatus: UILabel!
  @IBOutlet weak var lblGameRegion: UILabel!
  @IBOutlet weak var btnCheck: UIButton!
  
  func update(
    musume: Musume,
    finishedRaceCount: Int,
    isCurrent: Bool,
    selectMode: MusumeCollectionViewController.SelectMode,
    isMultiSelected: Bool
  ) {
    btnCheck.layer.borderWidth = 1
    btnCheck.layer.borderColor = UIColor.gray.cgColor
    
    if selectMode == .multipleSelect && !isCurrent {
      btnCheck.isHidden = false
      btnCheck.isEnabled = true
      
      if isMultiSelected {
        let symbolConfig = UIImage.SymbolConfiguration(
          pointSize: 10,
          weight: .regular,
          scale: .default
        )
        btnCheck.setImage(
          UIImage(
            systemName: "checkmark",
            withConfiguration: symbolConfig
          ),
          for: .normal
        )
      } else {
        btnCheck.setImage(nil, for: .normal)
      }
    } else {
      btnCheck.isHidden = true
      btnCheck.isEnabled = false
    }
    
    
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

protocol MusumeColletionHeaderDelegate: AnyObject {
  func didTriggeredBtnActMultiSelect_Delete()
  func didTriggeredBtnActCancel()
}

class MusumeCollectionHeaderCell: UICollectionReusableView {
  @IBOutlet weak var btnModeSelect_Delete: UIButton!
  @IBOutlet weak var btnCancel: UIButton!
  @IBOutlet weak var btnAddNewMusume: UIButton!
  
  weak var delegate: MusumeColletionHeaderDelegate?
  
  // MARK: - IBActions
  
  @IBAction func btnActMultiSelect_Delete(_ sender: UIButton) {
    delegate?.didTriggeredBtnActMultiSelect_Delete()
  }
  
  @IBAction func btnActCancel(_ sender: UIButton) {
    delegate?.didTriggeredBtnActCancel()
  }
}
