//
//  GameAppRegion.swift
//  MezaseZenkan
//
//  Created by 윤범태 on 7/16/25.
//

import Foundation

enum GameAppRegion: String, CaseIterable {
  case ja
  case ko
  
  var localizedDescription: String {
    switch self {
    case .ja: "loc.region_ja"
    case .ko: "loc.region_ko"
    }
  }
  
  var code: String {
    rawValue
  }
  
  var monthText: String {
    switch self {
    case .ja: "月"
    case .ko: "월"
    }
  }
  
  var leftText: String {
    switch self {
    case .ja: "左"
    case .ko: "좌"
    }
  }
  
  var rightText: String {
    switch self {
    case .ja: "右"
    case .ko: "우"
    }
  }
}
