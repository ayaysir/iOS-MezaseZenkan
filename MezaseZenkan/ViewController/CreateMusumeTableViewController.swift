//
//  CreateMusumeTableViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import UIKit
import Mantis

protocol CreateMusumeTVCDelegate: AnyObject {
  func didAddedMusume(_ controller: CreateMusumeTableViewController, addedMusume: Musume)
}

class CreateMusumeTableViewController: UITableViewController {
  var musumeViewModel: MusumeViewModel!
  weak var delegate: CreateMusumeTVCDelegate?
  let imagePickerController = UIImagePickerController()
  
  var currentFileName = "fuyuurara.png"
  var currentFileDirectory = "APP_RESOURCE"
  
  @IBOutlet weak var txfName: UITextField!
  @IBOutlet weak var imgViewProfile: UIImageView!
  @IBOutlet weak var pkvSelectRegion: UIPickerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePickerController.delegate = self
    pkvSelectRegion.delegate = self
    pkvSelectRegion.dataSource = self
  }
  
  @IBAction func btnActAddCharacter(_ sender: UIButton) {
    guard let name = txfName.text else {
      simpleAlert(self, message: "名前を入力する必要があります。")
      return
    }
    
    guard name.count >= 1 && name.count <= 25 else {
      simpleAlert(self, message: "名前は1文字以上25文字以下でなければなりません。")
      return
    }
    
    // 중복 검사
    guard !musumeViewModel.isNameDuplicated(name: name) else {
      simpleAlert(self, message: "すでに重複した名前があります。 別の名前で試してみてください。")
      return
    }
    
    if let delegate = delegate {
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
      
      simpleAlert(self, message: "新しいキャラクター追加が完了しました。", title: "完了") { action in
        delegate.didAddedMusume(self, addedMusume: musume)
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func btnActCancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func btnActPhotoLibrary(_ sender: Any) {
    authPhotoLibrary(self) {
      self.imagePickerController.sourceType = .photoLibrary
      self.present(self.imagePickerController, animated: true, completion: nil)
    }
  }
  
  @IBAction func btnActCamera(_ sender: Any) {
    authDeviceCamera(self) {
      self.imagePickerController.sourceType = .camera
      self.present(self.imagePickerController, animated: true, completion: nil)
    }
  }
}

extension CreateMusumeTableViewController: CropViewControllerDelegate {
  func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
    
    imgViewProfile.image = cropped
    currentFileName = "\(UUID().uuidString).png"
    currentFileDirectory = "documents"
    cropped.saveToDocuments(filename: currentFileName)
    cropViewController.dismiss(animated: true, completion: nil)
  }
  
  func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
    print(#function)
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
