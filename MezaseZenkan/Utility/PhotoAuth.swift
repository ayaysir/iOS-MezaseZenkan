//
//  PhotoAuth.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import UIKit
import Photos

private func photoAuth(isCamera: Bool, viewController: UIViewController, completion: @escaping () -> ()) {
  let sourceName = isCamera ? "カメラ" : "写真ライブラリ"
  let notDeterminedAlertTitle = "No Permission Status"
  let notDeterminedMsg = "\(sourceName)の権限設定を変更してもよろしいですか？"
  let restrictedMsg = "システムによって拒否されました。"
  let deniedAlertTitle = "Permission Denied"
  let deniedMsg = "\(sourceName)の権限は拒否され、使用できません。 \(sourceName)の権限設定を変更しますか？"
  let unknownMsg = "unknown"
  let status: Int = isCamera
  ? AVCaptureDevice.authorizationStatus(for: AVMediaType.video).rawValue
  : PHPhotoLibrary.authorizationStatus().rawValue
  
  // PHAuthorizationStatus
  // AVAuthorizationStatus
  switch status {
  case 0:
    // .notDetermined
    simpleDestructiveYesAndNo(viewController, message: notDeterminedMsg, title: notDeterminedAlertTitle, yesHandler: openSettings)
    print("CALLBACK FAILED: \(sourceName) is .notDetermined")
  case 1:
    // .restricted
    simpleAlert(viewController, message: restrictedMsg)
    print("CALLBACK FAILED: \(sourceName) is .restricted")
  case 2:
    // .denied
    simpleDestructiveYesAndNo(viewController, message: deniedMsg, title: deniedAlertTitle, yesHandler: openSettings)
    print("CALLBACK FAILED: \(sourceName) is .denied")
  case 3:
    // .authorized
    print("CALLBACK SUCCESS: \(sourceName) is .authorized")
    completion()
  case 4:
    // .limited (라이브러리 전용)
    print("CALLBACK SUCCESS: \(sourceName) is .limited")
    completion()
  default:
    simpleAlert(viewController, message: unknownMsg)
    print("CALLBACK FAILED: \(sourceName) is unknwon state.")
  }
}

private func openSettings(action: UIAlertAction) -> Void {
  guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
    return
  }
  
  if UIApplication.shared.canOpenURL(settingsUrl) {
    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
      print("Settings opened: \(success)") // Prints true
    })
  }
}

// MARK: - photoAuth 함수를 main 스레드에서 실행 (UI 관련 문제 방지)
private func photoAuthInMainAsync(isCamera: Bool, viewController: UIViewController, completion: @escaping () -> ()) {
  DispatchQueue.main.async {
    photoAuth(isCamera: isCamera, viewController: viewController, completion: completion)
  }
}

// MARK: - 사진 라이브러리의 권한을 묻고, 이후 () -> () 클로저를 실행하는 함수
func authPhotoLibrary(_ viewController: UIViewController, completion: @escaping () -> ()) {
  PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
    photoAuthInMainAsync(isCamera: false, viewController: viewController, completion: completion)
  }
}

// MARK: - 카메라의 권한을 묻고, 이후 () -> () 클로저를 실행하는 함수
func authDeviceCamera(_ viewController: UIViewController, completion: @escaping () -> ()) {
  let notAvailableMsg = "カメラの使用はできません。"
  
  if UIImagePickerController.isSourceTypeAvailable(.camera) {
    AVCaptureDevice.requestAccess(for: .video) { status in
      photoAuthInMainAsync(isCamera: true, viewController: viewController, completion: completion)
    }
  } else {
    // 시뮬레이터 등에서 카메라를 사용할 수 없는 경우
    DispatchQueue.main.async {
      simpleAlert(viewController, message: notAvailableMsg)
    }
  }
}
