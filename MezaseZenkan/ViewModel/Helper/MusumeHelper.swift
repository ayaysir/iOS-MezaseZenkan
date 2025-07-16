//
//  MusumeHelper.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/07.
//

import UIKit

class MusumeHelper {
  static func getImage(of musume: Musume) -> UIImage? {
    if musume.imgDirectory == "APP_RESOURCE" && musume.imgProfile == "fuyuurara.png" {
      return UIImage(named: "fuyuurara")
    }
    
    if musume.imgDirectory == "APP_RESOURCE" {
      return UIImage(named: "images/\(musume.imgProfile)")
    } else {
      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
      let userDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
      let paths               = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
      
      if let dirPath          = paths.first {
        let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("\(musume.imgProfile)")
        return UIImage(contentsOfFile: imageURL.path)
      }
    }
    
    return UIImage(named: "fuyuurara")
  }
  
  static func extractRegionValue(from text: String) -> String? {
    let components = text.split(separator: "|") // "|" 기준 분리
    
    for component in components {
      let pair = component.split(separator: ":", maxSplits: 1)
      if pair.count == 2, pair[0] == "region" {
        return String(pair[1])
      }
    }
    
    return nil
  }
  
  static func extractGameAppRegion(from comment: String) -> GameAppRegion {
    return if let code = Self.extractRegionValue(from: comment), code == "ko" {
      .ko
    } else {
      .ja
    }
  }
}


