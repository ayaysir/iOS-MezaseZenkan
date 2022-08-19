//
//  초기설정(필독).swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import Foundation

/**
 - 시판용 true, 개발용 false
 - 시판용인 경우 targets 설정 -> BuildPhases -> Copy Bundle Resources 에서 images 폴더 제거 (만약을 위해)
 - 개발용은 설치 전에 false 로 설정, images 폴더 포함한 상태로 설치
 */
let PRODUCT_MODE = false
let SHOW_AD = true
