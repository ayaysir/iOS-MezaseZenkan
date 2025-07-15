//
//  InitialSetting(MustRead).swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import Foundation

func checkAppFirstrunOrUpdateStatus(firstrun: () -> (), updated: () -> (), nothingChanged: () -> ()) {
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
    
    if versionOfLastRun == nil {
        // First start after installing the app
        firstrun()
    } else if versionOfLastRun != currentVersion {
        // App was updated since last run
        updated()
    } else {
        // nothing changed
        nothingChanged()
    }
    
    UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
    UserDefaults.standard.synchronize()
}

/**
 Ver 1.0
 - 시판용 true, 개발용 false
 - 시판용인 경우 targets 설정 -> BuildPhases -> Copy Bundle Resources 에서 images 폴더 제거 (만약을 위해)
 - 개발용은 설치 전에 false 로 설정, images 폴더 포함한 상태로 설치
 */
// let PRODUCT_MODE = false
// let SHOW_AD = true

/**
 Ver 1.1
 - PRODUCT_MODE 변수 제거 후 아래로 대체
 - 배너 변경 변수 생성 (UserDefaults key: ShowHighResBanner)
 */
let SET_REAL_MUSUME_DATA = false
let SHOW_AD = true
extension String {
    static let cfgShowHighResBanner = "ShowHighResBanner"
}
