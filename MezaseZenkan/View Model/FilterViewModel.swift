//
//  FilterViewModel.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/01.
//

import Foundation

enum FilterCondition {
    case junior, classic, senior, g1, g2, g3, grass, dirt, short, mile, intermediate, long, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, firstHalf, secondHalf, reset
}

class FilterViewModel {
    
    private var filterMenus: [FilterMenu] = [
        FilterMenu(displayName: "junior", filterCondition: .junior, section: 0),
        FilterMenu(displayName: "classic", filterCondition: .classic, section: 0),
        FilterMenu(displayName: "senior", filterCondition: .senior, section: 0),
        FilterMenu(displayName: "G1", filterCondition: .g1, section: 1),
        FilterMenu(displayName: "G2", filterCondition: .g2, section: 1),
        FilterMenu(displayName: "G3", filterCondition: .g3, section: 1),
        FilterMenu(displayName: "芝", filterCondition: .grass, section: 2),
        FilterMenu(displayName: "ダート", filterCondition: .dirt, section: 2),
        FilterMenu(displayName: "短距離", filterCondition: .short, section: 3),
        FilterMenu(displayName: "マイル", filterCondition: .mile, section: 3),
        FilterMenu(displayName: "中距離", filterCondition: .intermediate, section: 3),
        FilterMenu(displayName: "長距離", filterCondition: .long, section: 3),
        FilterMenu(displayName: "1月", filterCondition: .m1, section: 4),
        FilterMenu(displayName: "2月", filterCondition: .m2, section: 4),
        FilterMenu(displayName: "3月", filterCondition: .m3, section: 4),
        FilterMenu(displayName: "4月", filterCondition: .m4, section: 4),
        FilterMenu(displayName: "5月", filterCondition: .m5, section: 4),
        FilterMenu(displayName: "6月", filterCondition: .m6, section: 4),
        FilterMenu(displayName: "7月", filterCondition: .m7, section: 5),
        FilterMenu(displayName: "8月", filterCondition: .m8, section: 5),
        FilterMenu(displayName: "9月", filterCondition: .m9, section: 5),
        FilterMenu(displayName: "10月", filterCondition: .m10, section: 5),
        FilterMenu(displayName: "11月", filterCondition: .m11, section: 5),
        FilterMenu(displayName: "12月", filterCondition: .m12, section: 5),
        FilterMenu(displayName: "前半", filterCondition: .firstHalf, section: 6),
        FilterMenu(displayName: "後半", filterCondition: .secondHalf, section: 6),
        FilterMenu(displayName: "reset", filterCondition: .reset, section: 7),
        
    ]
    
    var count: Int {
        return filterMenus.count
    }
    
    func getFilterBy(row: Int) -> FilterMenu {
        return filterMenus[row]
    }
    
    func getSectionCount(section: Int) -> Int {
        return filterMenus.filter { $0.section == section }.count
    }
    
    func getSectionCountOf(menu: FilterMenu) -> Int {
        let section = menu.section
        return getSectionCount(section: section)
    }
    
    func getSectionCountOf(index: Int) -> Int {
        let section = filterMenus[index].section
        return getSectionCount(section: section)
    }
}


