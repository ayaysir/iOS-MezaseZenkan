//
//  CreateMusumeTableViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import UIKit
import Mantis

protocol CreateMusumeTVCDelegate: AnyObject {
  func didAddedMusume(
    _ controller: CreateMusumeTableViewController,
    addedMusume: Musume
  )
  func didUpdatedMusume(
    _ controller: CreateMusumeTableViewController,
    updatedMusume: Musume
  )
}

class CreateMusumeTableViewController: UITableViewController {
  let SECTION_NAME = 1
  let SECTION_APP_REGION = 2
  let SECTION_PHOTO = 3
  
  enum Mode {
    case create, update
    var localizedSubmitText: String {
      switch self {
      case .create:
        "loc.create".localized
      case .update:
        "loc.update".localized
      }
    }
    
    var localizedTitleText: String {
      switch self {
      case .create:
        "loc.create_musume".localized
      case .update:
        "loc.update_musume".localized
      }
    }
  }
  var mode: Mode = .create
  var musumeToUpdate: Musume?
  var musumeViewModel: MusumeViewModel!
  weak var delegate: CreateMusumeTVCDelegate?
  let imagePickerController = UIImagePickerController()
  
  var currentFileName = "fuyuurara.png"
  var currentFileDirectory = "APP_RESOURCE"
  
  @IBOutlet weak var txfName: UITextField!
  @IBOutlet weak var imgViewProfile: UIImageView!
  @IBOutlet weak var pkvSelectRegion: UIPickerView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var btnSubmit: UIButton!
  @IBOutlet weak var btnCancel: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePickerController.delegate = self
    pkvSelectRegion.delegate = self
    pkvSelectRegion.dataSource = self
    
    // Localization
    btnSubmit.setTitle(mode.localizedSubmitText, for: .normal)
    btnCancel.setTitle("loc.cancel".localized, for: .normal)
    lblTitle.text = mode.localizedTitleText
    
    if mode == .update, let musumeToUpdate {
      txfName.text = musumeToUpdate.name
      txfName.isEnabled = false
      txfName.textColor = .gray
      imgViewProfile.image = MusumeHelper.getImage(of: musumeToUpdate)

      switch MusumeHelper.extractGameAppRegion(from: musumeToUpdate.comment) {
      case .ja:
        pkvSelectRegion.selectRow(0, inComponent: 0, animated: false)
      case .ko:
        pkvSelectRegion.selectRow(1, inComponent: 0, animated: false)
      }
      pkvSelectRegion.isUserInteractionEnabled = false
      pkvSelectRegion.alpha = 0.5
    }
  }
  
  @IBAction func btnActAddCharacter(_ sender: UIButton) {
    // 공통: 유효성 검사
    
    guard let name = txfName.text else {
      simpleAlert(self, message: "loc.name_required".localized)
      return
    }
    
    guard name.count >= 1 && name.count <= 25 else {
      simpleAlert(self, message: "loc.name_length_limit".localized)
      return
    }
    
    // 중복 검사
    if mode == .create && musumeViewModel.isNameDuplicated(name: name) {
      simpleAlert(self, message: "loc.name_duplicated".localized)
      return
    }
    
    if let delegate {
      currentFileName = "\(txfName.text ?? UUID().uuidString).png"
      currentFileDirectory = "documents"
      
      let imgProfileName = currentFileName
      let imgDirectory = currentFileDirectory
      let regionCode = switch pkvSelectRegion.selectedRow(inComponent: 0) {
      case 0:
        GameAppRegion.ja.code
      case 1:
        GameAppRegion.ko.code
      default:
        ""
      }
      
      switch mode {
      case .create:
        createMusume(
          name: name,
          regionCode: regionCode,
          imgProfileName: imgProfileName,
          imgDirectory: imgDirectory,
          delegate: delegate
        )
      case .update:
        updateMusume(
          name: name,
          regionCode: regionCode,
          imgProfileName: imgProfileName,
          imgDirectory: imgDirectory,
          delegate: delegate
        )
      }
      
      if let image = imgViewProfile.image {
        image.saveToDocuments(filename: currentFileName)
      }
    }
  }
  
  @IBAction func btnActCancel(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func btnActPhotoLibrary(_ sender: UIButton) {
    authPhotoLibrary(self) {
      self.imagePickerController.sourceType = .photoLibrary
      self.present(self.imagePickerController, animated: true, completion: nil)
    }
  }
  
  @IBAction func btnActCamera(_ sender: UIButton) {
    authDeviceCamera(self) {
      self.imagePickerController.sourceType = .camera
      self.present(self.imagePickerController, animated: true, completion: nil)
    }
  }
  
  // MARK: - TableView Delegate
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case SECTION_NAME:
      "loc.section_name".localized
    case SECTION_PHOTO:
      "loc.section_photo".localized
    case SECTION_APP_REGION:
      "loc.section_app_region".localized
    default:
      super.tableView(tableView, titleForHeaderInSection: section)
    }
  }
}

extension CreateMusumeTableViewController {
  private func createMusume(
    name: String,
    regionCode: String,
    imgProfileName: String,
    imgDirectory: String,
    delegate: CreateMusumeTVCDelegate
  ) {
    let musume = Musume(
      name: name,
      nameEn: "",
      cv: "",
      birthday: "",
      height: 0,
      weight: "",
      b: 0,
      w: 0,
      h: 0,
      comment: "region:\(regionCode)|",
      catchphrase: "",
      imgProfile: imgProfileName,
      imgDirectory: imgDirectory,
      isAvailable: true
    )
    musumeViewModel.addMusume(musume)
    
    simpleAlert(self, message: "loc.character_add_success".localized, title: "loc.complete".localized) { action in
      delegate.didAddedMusume(self, addedMusume: musume)
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  private func updateMusume(
    name: String,
    regionCode: String,
    imgProfileName: String,
    imgDirectory: String,
    delegate: CreateMusumeTVCDelegate
  ) {
    guard var musumeToUpdate, let index = musumeViewModel.findIndex(of: musumeToUpdate) else {
      return
    }
    
    musumeToUpdate.name = name
    musumeToUpdate.comment = "region:\(regionCode)|"
    musumeToUpdate.imgProfile = imgProfileName
    musumeToUpdate.imgDirectory = imgDirectory
    
    musumeViewModel.updateMusume(musumeToUpdate, replaceTo: index)
    simpleAlert(self, message: "loc.update_success".localized, title: "loc.complete".localized) { action in
      delegate.didUpdatedMusume(self, updatedMusume: musumeToUpdate)
      self.dismiss(animated: true, completion: nil)
    }
  }
}

extension CreateMusumeTableViewController: CropViewControllerDelegate {
  func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
    
    imgViewProfile.image = cropped
    cropViewController.dismiss(animated: true, completion: nil)
  }
  
  func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
    cropViewController.dismiss(animated: true, completion: nil)
  }
  
  func popupCropVC(image: UIImage?) {
    
    guard let image = image else {
      return
    }
    
    let cropViewController = Mantis.cropViewController(image: image)
    cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1.0)
    cropViewController.delegate = self
    cropViewController.modalPresentationStyle = .overFullScreen
    self.present(cropViewController, animated: true)
  }
}

extension CreateMusumeTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      dismiss(animated: false) {
        self.popupCropVC(image: image)
      }
    }
    dismiss(animated: true, completion: nil)
  }
}

extension CreateMusumeTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    GameAppRegion.allCases.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    GameAppRegion.allCases[row].localizedDescription
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let selected = GameAppRegion.allCases[row]
    print("선택됨: \(selected)")
  }
}
