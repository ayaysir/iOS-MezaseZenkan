//
//  FilterHelper.swift
//  MezaseZenkan
//
//  Created by 윤범태 on 7/16/25.
//

import UIKit

struct FilterHelper {
  static var region: GameAppRegion = .ja
  
  private static var filterMenuArray: [FilterMenu] {
    func T(_ filterCondition: FilterCondition) -> String {
      filterCondition.regionDescription(of: region)
    }
    return [
      FilterMenu(searchName: "junior", filterCondition: .junior, section: .period, displayOrder: 0),
      FilterMenu(searchName: "classic", filterCondition: .classic, section: .period, displayOrder: 1),
      FilterMenu(searchName: "senior", filterCondition: .senior, section: .period, displayOrder: 2),
      FilterMenu(searchName: "classicsenior", filterCondition: .classicsenior, section: .period, displayOrder: -1),
      
      FilterMenu(
        searchName: T(.grass),
        filterCondition: .grass,
        section: .terrain,
        displayOrder: 3
      ),
      FilterMenu(
        searchName: T(.dirt),
        filterCondition: .dirt,
        section: .terrain,
        displayOrder: 4
      ),
      
      FilterMenu(searchName: T(.short), filterCondition: .short, section: .lengthType, displayOrder: 5),
      FilterMenu(searchName: T(.mile), filterCondition: .mile, section: .lengthType, displayOrder: 6),
      FilterMenu(searchName: T(.intermediate), filterCondition: .intermediate, section: .lengthType, displayOrder: 7),
      FilterMenu(searchName: T(.long), filterCondition: .long, section: .lengthType, displayOrder: 8),
      
      FilterMenu(searchName: T(.left), filterCondition: .left, section: .direction, displayOrder: 9),
      FilterMenu(searchName: T(.right), filterCondition: .right, section: .direction, displayOrder: 10),
      FilterMenu(searchName: T(.straight), filterCondition: .straight, section: .direction, displayOrder: 11),
      
      /*
       東京    中山    札幌    大井
       阪神    小倉    京都    函館
       福島    新潟    中京
       川崎    船橋    盛岡
       롱샹
       */
      FilterMenu(searchName: T(.tokyo), filterCondition: .tokyo, section: .place1, displayOrder: 11),
      FilterMenu(searchName: T(.nakayama), filterCondition: .nakayama, section: .place1, displayOrder: 12),
      FilterMenu(searchName: T(.hanshin), filterCondition: .hanshin, section: .place1, displayOrder: 15),
      FilterMenu(searchName: T(.kyoto), filterCondition: .kyoto, section: .place1, displayOrder: 17),
      FilterMenu(searchName: T(.oi), filterCondition: .oi, section: .place2, displayOrder: 14),
      FilterMenu(searchName: T(.sapporo), filterCondition: .sapporo, section: .place2, displayOrder: 13),
      FilterMenu(searchName: T(.kokura), filterCondition: .kokura, section: .place2, displayOrder: 16),
      FilterMenu(searchName: T(.hakodate), filterCondition: .hakodate, section: .place2, displayOrder: 18),
      FilterMenu(searchName: T(.fukushima), filterCondition: .fukushima, section: .place3, displayOrder: 19),
      FilterMenu(searchName: T(.niigata), filterCondition: .niigata, section: .place3, displayOrder: 20),
      FilterMenu(searchName: T(.chukyou), filterCondition: .chukyou, section: .place3, displayOrder: 21),
      FilterMenu(searchName: "", filterCondition: .emptyPlace, section: .place3, displayOrder: 22),
      
      FilterMenu(searchName: T(.kawasaki), filterCondition: .kawasaki, section: .place4, displayOrder: 23),
      FilterMenu(searchName: T(.funabashi), filterCondition: .funabashi, section: .place4, displayOrder: 24),
      FilterMenu(searchName: T(.morioka), filterCondition: .morioka, section: .place4, displayOrder: 25),
      FilterMenu(searchName: "", filterCondition: .emptyPlace2, section: .place4, displayOrder: 27),
      
      FilterMenu(searchName: T(.ronchamp), filterCondition: .ronchamp, section: .place5, displayOrder: 26),
      
      FilterMenu(searchName: "1\(region.monthText)", filterCondition: .m1, section: .monthUpper, displayOrder: 27),
      FilterMenu(searchName: "2\(region.monthText)", filterCondition: .m2, section: .monthUpper, displayOrder: 28),
      FilterMenu(searchName: "3\(region.monthText)", filterCondition: .m3, section: .monthUpper, displayOrder: 29),
      FilterMenu(searchName: "4\(region.monthText)", filterCondition: .m4, section: .monthUpper, displayOrder: 30),
      FilterMenu(searchName: "5\(region.monthText)", filterCondition: .m5, section: .monthUpper, displayOrder: 31),
      FilterMenu(searchName: "6\(region.monthText)", filterCondition: .m6, section: .monthUpper, displayOrder: 32),
      FilterMenu(searchName: "7\(region.monthText)", filterCondition: .m7, section: .monthLower, displayOrder: 33),
      FilterMenu(searchName: "8\(region.monthText)", filterCondition: .m8, section: .monthLower, displayOrder: 34),
      FilterMenu(searchName: "9\(region.monthText)", filterCondition: .m9, section: .monthLower, displayOrder: 35),
      FilterMenu(searchName: "10\(region.monthText)", filterCondition: .m10, section: .monthLower, displayOrder: 36),
      FilterMenu(searchName: "11\(region.monthText)", filterCondition: .m11, section: .monthLower, displayOrder: 37),
      FilterMenu(searchName: "12\(region.monthText)", filterCondition: .m12, section: .monthLower, displayOrder: 38),
      
      FilterMenu(searchName: T(.firstHalf), filterCondition: .firstHalf, section: .half, displayOrder: 39),
      FilterMenu(searchName: T(.secondHalf), filterCondition: .secondHalf, section: .half, displayOrder: 40),
      
      //        .g1: FilterMenu(searchName: "G1", filterCondition: .g1, section: .grade, displayOrder: 25),
      //        .g2: FilterMenu(searchName: "G2", filterCondition: .g2, section: .grade, displayOrder: 26),
      //        .g3: FilterMenu(searchName: "G3", filterCondition: .g3, section: .grade, displayOrder: 27),
      
      FilterMenu(searchName: "loc.reset".localized, filterCondition: .reset, section: .reset, displayOrder: 36),
    ]
  }
  
  static var filterMenus: [FilterCondition: FilterMenu] {
    filterMenuArray.filter({ $0.displayOrder >= 0 })
      .enumerated().reduce(into: [FilterCondition: FilterMenu]()) { partialResult, enumObj in
        var menu = enumObj.element
        if menu.displayOrder > 0 {
          menu.displayOrder = enumObj.offset
        }
        partialResult[menu.filterCondition] = menu
      }
  }
  
  private static var conditionToSection: [FilterCondition: FilterSection] {
    filterMenuArray.reduce(into: [FilterCondition: FilterSection]()) { partialResult, menu in
      partialResult[menu.filterCondition] = menu.section
    }
  }
  
  static func getConditionStyle(condition: FilterCondition) -> FilterStyle {
    let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
    let commonHighlight = RGB255(red: 0, green: 255, blue: 118).uiColor
    
    let conditionStyleMapper: [FilterCondition: [NSAttributedString.Key: Any]] = [
      .straight: [
        .backgroundColor: RGB255(red: 255, green: 198, blue: 194).uiColor,
        .foregroundColor: UIColor.black,
      ],
      .ronchamp: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .junior: [
        .backgroundColor: RGB255(red: 240, green: 240, blue: 240).uiColor,
        .foregroundColor: RGB255(red: 16, green: 148, blue: 84).uiColor,
        .font: boldFont,
      ],
      .classic: [
        .backgroundColor: RGB255(red: 240, green: 240, blue: 240).uiColor,
        .foregroundColor: RGB255(red: 23, green: 99, blue: 176).uiColor,
        .font: boldFont,
      ],
      .senior: [
        .backgroundColor: RGB255(red: 240, green: 240, blue: 240).uiColor,
        .foregroundColor: RGB255(red: 176, green: 23, blue: 79).uiColor,
        .font: boldFont,
      ],
      .classicsenior: [
        //                .font: UIFont(name: "HelveticaNeue-Bold", size: 13)!,
        //                .kern: -0.8,
        .backgroundColor: RGB255(red: 210, green: 230, blue: 255).uiColor,
        .foregroundColor: RGB255(red: 222, green: 75, blue: 127).uiColor,
        .font: boldFont,
      ],
      .g1: [
        .backgroundColor: RGB255(red: 40, green: 108, blue: 210).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .g2: [
        .backgroundColor: RGB255(red: 238, green: 57, blue: 111).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .g3: [
        .backgroundColor: RGB255(red: 49, green: 177, blue: 67).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .grass: [
        .backgroundColor: RGB255(red: 28, green: 83, blue: 67).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .dirt: [
        .backgroundColor: RGB255(red: 203, green: 16, blue: 20).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .short: [
        .backgroundColor: RGB255(red: 252, green: 85, blue: 160).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .mile: [
        .backgroundColor: RGB255(red: 185, green: 228, blue: 94).uiColor,
        .foregroundColor: UIColor.black,
        .font: boldFont,
      ],
      .intermediate: [
        .backgroundColor: RGB255(red: 252, green: 172, blue: 10).uiColor,
        .foregroundColor: RGB255(red: 50, green: 50, blue: 50).uiColor,
        .font: boldFont,
      ],
      .long: [
        .backgroundColor: RGB255(red: 40, green: 90, blue: 170).uiColor,
        .foregroundColor: UIColor.white,
        .font: boldFont,
      ],
      .m1: [
        .backgroundColor: RGB255(red: 189, green: 195, blue: 229).uiColor
      ],
      .m2: [
        .backgroundColor: RGB255(red: 249, green: 157, blue: 179).uiColor
      ],
      .m3: [
        .backgroundColor: RGB255(red: 206, green: 228, blue: 212).uiColor
      ],
      .m4: [
        .backgroundColor: RGB255(red: 247, green: 232, blue: 128).uiColor
      ],
      .m5: [
        .backgroundColor: RGB255(red: 24, green: 159, blue: 132).uiColor,
        .foregroundColor: UIColor.white
      ],
      .m6: [
        .backgroundColor: RGB255(red: 213, green: 213, blue: 242).uiColor
      ],
      .m7: [
        .backgroundColor: RGB255(red: 208, green: 225, blue: 248).uiColor
      ],
      .m8: [
        .backgroundColor: RGB255(red: 246, green: 175, blue: 172).uiColor
      ],
      .m9: [
        .backgroundColor: RGB255(red: 208, green: 215, blue: 58).uiColor
      ],
      .m10: [
        .backgroundColor: RGB255(red: 248, green: 253, blue: 120).uiColor
      ],
      .m11: [
        .backgroundColor: RGB255(red: 249, green: 187, blue: 95).uiColor
      ],
      .m12: [
        .backgroundColor: RGB255(red: 224, green: 234, blue: 230).uiColor
      ],
      .left: [
        .backgroundColor: RGB255(red: 255, green: 198, blue: 194).uiColor,
        .foregroundColor: UIColor.black,
      ],
      .right: [
        .backgroundColor: RGB255(red: 194, green: 194, blue: 255).uiColor,
        .foregroundColor: UIColor.black,
      ],
      .firstHalf: [
        .backgroundColor: RGB255(red: 200, green: 255, blue: 195).uiColor,
        .foregroundColor: UIColor.black,
      ],
      .secondHalf: [
        .backgroundColor: RGB255(red: 230, green: 195, blue: 255).uiColor,
        .foregroundColor: UIColor.black,
      ],
      .reset: [:],
      .chukyou: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .niigata: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .fukushima: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .hakodate: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .kyoto: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .hanshin: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .oi: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .kokura: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .sapporo: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .tokyo: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .nakayama: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .funabashi: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .kawasaki: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
      .morioka: [
        .backgroundColor: commonHighlight,
        .font: boldFont,
      ],
    ]
    
    return FilterStyle(targetSection: getSection(of: condition), style: conditionStyleMapper[condition]!)
  }
  
  static var displayMenuCount: Int {
    return filterMenus.filter({ $0.value.displayOrder >= 0 }).count
  }
  
  static func getFilterMenuBy(row: Int) -> FilterMenu? {
    return filterMenus.first(where: { $0.value.displayOrder == row })?.value
  }
  
  static func getFilterMenuBy(condition: FilterCondition) -> FilterMenu {
    return filterMenus[condition]!
  }
  
  static func getSection(of condition: FilterCondition) -> FilterSection {
    return conditionToSection[condition]!
  }
  
  static func getSectionCount(section: FilterSection) -> Int {
    return filterMenus.filter { $0.value.section == section && $0.value.displayOrder >= 0 }.count
  }
  
  static func getSectionCountOfIndex(row: Int) -> Int? {
    if let filterCondition = getFilterMenuBy(row: row) {
      return getSectionCount(section: filterCondition.section)
    }
    return nil
  }
  
  static func getSectionCountOf(menu: FilterMenu) -> Int {
    let section = menu.section
    return getSectionCount(section: section)
  }
}
