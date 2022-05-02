//
//  FilterViewModel.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/01.
//

import UIKit

enum FilterCondition: String {
    case junior, classic, senior, g1, g2, g3, grass, dirt, short, mile, intermediate, long, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, left, right, firstHalf, secondHalf, reset, classicsenior
}

enum FilterSection: Int {
    case period = 0
    case place = 1
    case terrain = 2
    case lengthType = 3
    case monthUpper = 4
    case monthLower = 5
    case direction = 6
    case half = 7
    case grade = 8
    case reset = 9
}

struct FilterStyle {
    var targetSection: FilterSection
    var style: [NSAttributedString.Key: Any]
}

struct FilterHelper {
    
    static let filterMenus: [FilterCondition: FilterMenu] = [
        .junior: FilterMenu(searchName: "junior", filterCondition: .junior, section: .period, displayOrder: 0),
        .classic: FilterMenu(searchName: "classic", filterCondition: .classic, section: .period, displayOrder: 1),
        .senior: FilterMenu(searchName: "senior", filterCondition: .senior, section: .period, displayOrder: 2),
        .classicsenior: FilterMenu(searchName: "classicsenior", filterCondition: .classicsenior, section: .period, displayOrder: -1),
        
            .grass: FilterMenu(searchName: "芝", filterCondition: .grass, section: .terrain, displayOrder: 3),
        .dirt: FilterMenu(searchName: "ダート", filterCondition: .dirt, section: .terrain, displayOrder: 4),
        
            .short: FilterMenu(searchName: "短距離", filterCondition: .short, section: .lengthType, displayOrder: 5),
        .mile: FilterMenu(searchName: "マイル", filterCondition: .mile, section: .lengthType, displayOrder: 6),
        .intermediate: FilterMenu(searchName: "中距離", filterCondition: .intermediate, section: .lengthType, displayOrder: 7),
        .long: FilterMenu(searchName: "長距離", filterCondition: .long, section: .lengthType, displayOrder: 8),
        
            .left: FilterMenu(searchName: "左", filterCondition: .left, section: .direction, displayOrder: 9),
        .right: FilterMenu(searchName: "右", filterCondition: .right, section: .direction, displayOrder: 10),
        
            .m1: FilterMenu(searchName: "1月", filterCondition: .m1, section: .monthUpper, displayOrder: 11),
        .m2: FilterMenu(searchName: "2月", filterCondition: .m2, section: .monthUpper, displayOrder: 12),
        .m3: FilterMenu(searchName: "3月", filterCondition: .m3, section: .monthUpper, displayOrder: 13),
        .m4: FilterMenu(searchName: "4月", filterCondition: .m4, section: .monthUpper, displayOrder: 14),
        .m5: FilterMenu(searchName: "5月", filterCondition: .m5, section: .monthUpper, displayOrder: 15),
        .m6: FilterMenu(searchName: "6月", filterCondition: .m6, section: .monthUpper, displayOrder: 16),
        .m7: FilterMenu(searchName: "7月", filterCondition: .m7, section: .monthLower, displayOrder: 17),
        .m8: FilterMenu(searchName: "8月", filterCondition: .m8, section: .monthLower, displayOrder: 18),
        .m9: FilterMenu(searchName: "9月", filterCondition: .m9, section: .monthLower, displayOrder: 19),
        .m10: FilterMenu(searchName: "10月", filterCondition: .m10, section: .monthLower, displayOrder: 20),
        .m11: FilterMenu(searchName: "11月", filterCondition: .m11, section: .monthLower, displayOrder: 21),
        .m12: FilterMenu(searchName: "12月", filterCondition: .m12, section: .monthLower, displayOrder: 22),
        
            .firstHalf: FilterMenu(searchName: "前半", filterCondition: .firstHalf, section: .half, displayOrder: 23),
        .secondHalf: FilterMenu(searchName: "後半", filterCondition: .secondHalf, section: .half, displayOrder: 24),
        
        //        .g1: FilterMenu(searchName: "G1", filterCondition: .g1, section: .grade, displayOrder: 25),
        //        .g2: FilterMenu(searchName: "G2", filterCondition: .g2, section: .grade, displayOrder: 26),
        //        .g3: FilterMenu(searchName: "G3", filterCondition: .g3, section: .grade, displayOrder: 27),
        
            .reset: FilterMenu(searchName: "reset", filterCondition: .reset, section: .reset, displayOrder: 25),
    ]
    
    static func getConditionStyle(condition: FilterCondition) -> FilterStyle {
        
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
        
        let conditionStyleMapper: [FilterCondition: [NSAttributedString.Key: Any]] = [
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
                .foregroundColor: UIColor.black,
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
        ]
        return FilterStyle(targetSection: filterMenus[condition]!.section, style: conditionStyleMapper[condition]!)
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
        return filterMenus[condition]!.section
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

class FilterViewModel {
    
    private var _currentFilterConditions: Set<FilterCondition> = []
    
    func toggleCurrentCondition(condition: FilterCondition) {
        
        if _currentFilterConditions.contains(condition) {
            _currentFilterConditions.remove(condition)
        } else {
            _currentFilterConditions.insert(condition)
        }
    }
    
    func reset() {
        _currentFilterConditions = []
    }
    
    func getRefinedConditionsBy(race: Race) -> Set<FilterCondition> {
        
        var refinedConditions = _currentFilterConditions.filter { condition in
            
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
            case .monthUpper:
                return Int(menu.searchName.replacingOccurrences(of: "月", with: "")) == race.month
            case .monthLower:
                return Int(menu.searchName.replacingOccurrences(of: "月", with: "")) == race.month
            case .direction:
                if menu.searchName == "右" {
                    return race.direction.contains("右")
                }
                return menu.searchName == race.direction
            case .half:
                return menu.searchName == race.half
            case .place:
                return menu.searchName == race.place
            case .reset:
                return false
            }
        }
        
        if _currentFilterConditions.contains(.classic)
            && _currentFilterConditions.contains(.senior)
            && race.period == "classicsenior"
        {
            refinedConditions.insert(.classicsenior)
            refinedConditions.remove(.classic)
            refinedConditions.remove(.senior)
        }
        
        return refinedConditions
    }
    
    var currentFilterConditions: Set<FilterCondition> {
        return _currentFilterConditions
    }
    
}


