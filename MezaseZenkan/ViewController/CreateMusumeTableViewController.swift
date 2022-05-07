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

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController.delegate = self
    }

    @IBAction func btnActAddCharacter(_ sender: Any) {
        
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
            let musume = Musume(name: name, nameEn: "", cv: "", birthday: "", height: 0, weight: "", b: 0, w: 0, h: 0, comment: "", catchphrase: "", imgProfile: imgProfileName, imgDirectory: imgDirectory, isAvailable: true)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
