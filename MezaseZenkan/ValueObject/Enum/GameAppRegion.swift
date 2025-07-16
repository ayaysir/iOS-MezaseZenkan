//
//  GameAppRegion.swift
//  MezaseZenkan
//
//  Created by 윤범태 on 7/16/25.
//

import Foundation

enum GameAppRegion: CaseIterable {
  case ja
  case ko
  
  var localizedDescription: String {
    switch self {
    case .ja:
      return "loc.region_ja"
    case .ko:
      return "loc.region_ko"
    }
  }
  
  var code: String {
    switch self {
    case .ja:
      return "ja"
    case .ko:
      return "ko"
    }
  }
}
