//
//  AttributedStringMaker.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/30.
//

import UIKit

enum RaceElement: Int {
    case period = 0, month = 2, grade = 4, terrain = 6, length = 8, lengthType = 10, direction = 13
}

typealias RaceElementHighlights = [RaceElement: [NSAttributedString.Key : Any]]
func attributedStringMaker(from race: Race, highlights: RaceElementHighlights = [:]) -> NSMutableAttributedString {
    
    /*
     classicsenior | 9月後半 | G1
     芝 | 1200m(短距離) | 右外
     */
    
    let period = race.period
    let monthAndHalf = "\(race.month)月\(race.half)"
    let grade = race.grade
    let terrain = race.terrain
    let length = "\(race.length)m"
    let lengthType = race.lengthType
    let direction = race.direction
    
    let BS = " | "
    let CR = "\n"
    
    let raceStringElements: [Int: String] = [
        0: period,
        1: BS,
        2: monthAndHalf,
        3: BS,
        4: grade,
        5: CR,
        6: terrain,
        7: BS,
        8: length,
        9: "(",
        10: lengthType,
        11: ")",
        12: BS,
        13: direction
    ]
    let raceString = (0..<raceStringElements.count).reduce("", { $0 + raceStringElements[$1]! })
    let attributedString = NSMutableAttributedString(string: raceString)
    print(raceString, highlights)
    
    for highlight in highlights {
        let attribute: [NSAttributedString.Key: Any] = highlight.value
        let start = 0
        print(raceStringElements[highlight.key.rawValue]!)
        let length = raceStringElements[highlight.key.rawValue]!.count
        let range: NSRange = NSRange(location: start, length: length)
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
