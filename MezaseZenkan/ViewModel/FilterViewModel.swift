//
//  FilterViewModel.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/01.
//

import Foundation

class FilterViewModel {
  private(set) var currentFilterConditions: Set<FilterCondition> = []
  var racesRegion: GameAppRegion = .ja {
    didSet {
      FilterHelper.region = racesRegion
    }
  }
  
  func toggleCurrentCondition(condition: FilterCondition) {
    if currentFilterConditions.contains(condition) {
      currentFilterConditions.remove(condition)
    } else {
      currentFilterConditions.insert(condition)
    }
  }
  
  func reset() {
    currentFilterConditions = []
  }
  
  func getRefinedConditionsBy(race: Race) -> Set<FilterCondition> {
    var refinedConditions = currentFilterConditions.filter { condition in
      let section = FilterHelper.getSection(of: condition)
      let menu = FilterHelper.getFilterMenuBy(condition: condition)
      
      switch section {
      case .period:
        return menu.searchName == race.period
      case .grade:
        return menu.searchName == race.grade
      case .terrain:
        return menu.searchName == race.terrain
      case .lengthType:
        return menu.searchName == race.lengthType
      case .monthUpper, .monthLower:
        return Int(menu.searchName.replacingOccurrences(of: racesRegion.monthText, with: "")) == race.month
      case .direction:
        if menu.searchName == racesRegion.rightText {
          return race.direction.contains(racesRegion.rightText)
        } else if menu.searchName == racesRegion.leftText {
          return race.direction.contains(racesRegion.leftText)
        }
        
        return menu.searchName == race.direction
      case .half:
        return menu.searchName == race.half
      case .reset:
        return false
      case .place1, .place2, .place3, .place4, .place5:
        return menu.searchName == race.place
      }
    }
    
    if currentFilterConditions.contains(.classic)
        && currentFilterConditions.contains(.senior)
        && race.period == "classicsenior"
    {
      refinedConditions.insert(.classicsenior)
      refinedConditions.remove(.classic)
      refinedConditions.remove(.senior)
    }
    
    return refinedConditions
  }
}
