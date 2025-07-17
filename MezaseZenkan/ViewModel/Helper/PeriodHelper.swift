//
//  Period.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/05.
//

import Foundation

class PeriodHelper {
  private init() {}
  static let shared = PeriodHelper()
  
  var month: Float = 7.0
  var year: Int = 1
  
  var yearText: String {
    switch year {
    case 1:
      return "junior"
    case 2:
      return "classic"
    case 3:
      return "senior"
    default:
      return ""
    }
  }
  
  var monthText: String {
    let whole = Int(modf(month).0)
    let fraction = modf(month).1
    return "\(whole)月 \(fraction == 0 ? "前半" : "後半")"
  }
  
  var localizedDescription: String {
    return "\(yearText)級 \(monthText) "
  }
  
  var isLastPeriod: Bool {
    return year == 3 && month == 12.5
  }
  
  var isFirstPeriod: Bool {
    return year == 1 && month == 7.0
  }
  
  func moveNextPeriod() {
    if month == 12.5 && year == 3 {
      return
    }
    
    if month <= 12.0 {
      month += 0.5
    } else {
      year += 1
      month = 1.0
    }
    
  }
  
  func movePrevPeriod() {
    if month == 7.0 && year == 1 {
      return
    }
    
    if month >= 1.5 {
      month -= 0.5
    } else {
      year -= 1
      month = 12.0
    }
  }
  
  func moveNextPeriodBigLeap() {
    if month == 12.5 && year == 3 {
      return
    }
    
    if year == 3 {
      month = 12.5
    } else {
      year += 1
    }
  }
  
  func movePrevPeriodBigLeap() {
    if month == 7.0 && year == 1 {
      return
    }
    
    if year == 1 {
      month = 7.0
    } else {
      year -= 1
    }
  }
}
