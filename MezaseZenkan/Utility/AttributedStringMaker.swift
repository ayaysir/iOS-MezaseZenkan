//
//  AttributedStringMaker.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/30.
//

import UIKit

//enum RaceElement: Int {
//    case period = 0, month = 2, grade = 4, terrain = 6, length = 8, lengthType = 10, direction = 13
//}

//typealias RaceElementHighlights = [RaceElement: [NSAttributedString.Key : Any]]

func attributedRaceStringMaker(from race: Race, filterConditions: Set<FilterCondition>) -> NSMutableAttributedString {
    
    /*
     classicsenior | 9月後半 | G1
     芝 | 1200m(短距離) | 右外
     */
    
    let period = race.period
    let month = "\(race.month)月"
    let half = race.half
    let place = race.place
    let grade = race.grade
    let terrain = race.terrain
    let length = "\(race.length)m"
    let lengthType = race.lengthType
    let direction = race.direction
    
    let BS = " | "
    let CR = "\n"
    
    /*
     0: period,
     1: BS,
     2: month,
     3: half,
     4: BS,
     5: place,
     6: CR,
     7: terrain,
     8: BS,
     9: length,
     10: "(",
     11: lengthType,
     12: ")",
     13: BS,
     14: direction
     */
    let raceStringElements: [String] = [
        period,
        BS,
        month,
        half,
        BS,
        place,
        CR,
        terrain,
        BS,
        length,
        "(",
        lengthType,
        ")",
        BS,
        direction,
    ]
    
    let sectionStartIndex: [FilterSection: Int] = [
        .period: 0,
        .monthLower: 2,
        .monthUpper: 2,
        .half: 3,
        .place1: 5,
        .place2: 5,
        .place3: 5,
        .place4: 5,
        .terrain: 7,
        .lengthType: 11,
        .direction: 14,
        
    ]
    
    let raceString = raceStringElements.reduce("", { $0 + $1 })
    let attributedString = NSMutableAttributedString(string: raceString)
    
    // 1차 공통 속성
    let commonAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "HelveticaNeue", size: 14)!
    ]
    attributedString.addAttributes(commonAttribute, range: NSRange(location: 0, length: raceString.count))
    if let csRange = raceString.range(of: "classicsenior") {
        let startIndex = raceString.distance(from: raceString.startIndex, to: csRange.lowerBound)
        attributedString.addAttributes([
            .font: UIFont(name: "HelveticaNeue", size: 13)!,
            .kern: -0.8
        ], range: NSRange(location: startIndex, length: "classicsenior".count))
    }
    
    // 2차 속성 - 막대기에 회색
    let bsAttribute: [NSAttributedString.Key: Any] = [
        .foregroundColor: RGB255(red: 125, green: 125, blue: 125).uiColor
    ]
    raceString.enumerated().forEach { (index, element) in
        if String(element) == "|" {
            let range = NSRange(location: index, length: 1)
            attributedString.addAttributes(bsAttribute, range: range)
        }
        
    }
    
    // 3차 속성 - 컨디션별 고유 속성
    for condition in filterConditions {
        
        let attribute: [NSAttributedString.Key: Any] = FilterHelper.getConditionStyle(condition: condition).style
        let sectionIndex = sectionStartIndex[FilterHelper.getSection(of: condition)]!
        
        let startPosition: Int = {
            
            if sectionIndex == 0 {
                return 0
            }
            
            return (0...(sectionIndex - 1)).reduce(0, { $0 + raceStringElements[$1].count })
        }()
        
        let length = raceStringElements[sectionIndex].count
        let range: NSRange = NSRange(location: startPosition, length: length)
        attributedString.addAttributes(attribute, range: range)
    }
    
    return attributedString
    
//    let attributedString = NSMutableAttributedString(string: "classicsenior | 9月後半 | G1\n芝 | 1200m(短距離) | 右外\n")
//
//    let attributes1: [NSAttributedString.Key : Any] = [
//       .foregroundColor: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
//    ]
//    attributedString.addAttributes(attributes1, range: NSRange(location: 14, length: 1))
//
//    let attributes3: [NSAttributedString.Key : Any] = [
//       .foregroundColor: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
//    ]
//    attributedString.addAttributes(attributes3, range: NSRange(location: 21, length: 1))
//
//    let attributes7: [NSAttributedString.Key : Any] = [
//       .foregroundColor: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
//    ]
//    attributedString.addAttributes(attributes7, range: NSRange(location: 28, length: 1))
//
//    let attributes9: [NSAttributedString.Key : Any] = [
//       .foregroundColor: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0)
//    ]
//    attributedString.addAttributes(attributes9, range: NSRange(location: 41, length: 1))

}
