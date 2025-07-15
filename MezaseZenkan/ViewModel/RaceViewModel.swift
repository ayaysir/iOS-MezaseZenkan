//
//  RaceViewModel.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/25.
//

import Foundation

class RaceViewModel {
    
    private var apiService: APIService!
    private var totalRaceData: [Race]! {
        didSet {
            
        }
    }
    
    private var g1Races: [Race]!
    private var g2Races: [Race]!
    private var g3Races: [Race]!
    private var raceChunksByTag: [[Race]]!
    private var tagRaceInfo: [String] = []
    
    var totalRaceCount: Int {
        return g1Races.count + g2Races.count + g3Races.count
    }
    
    var totalTagsCount: Int {
        return raceChunksByTag.count
    }
    
    var gradeCountArr: [Int] {
        return [g1Races.count, g2Races.count, g3Races.count]
    }
    
    var tagStartInfo: [String: Int] {
        
        return ["G1": tagRaceInfo.firstIndex(of: "G1")!,
                "G2": tagRaceInfo.firstIndex(of: "G2")!,
                "G3": tagRaceInfo.firstIndex(of: "G3")!]
    }
    
    init() {
        self.apiService =  APIService()
        getRaceDataFromServer()
    }
    
    func getViewCountBy(tag: Int) -> Int {
        return raceChunksByTag[tag].count
    }
    
    func getRaceBy(tag: Int, row: Int) -> Race {
        return raceChunksByTag[tag][row]
    }
    
    func getGradeBy(tag: Int) -> String {
        return tagRaceInfo[tag]
    }
    
    func getRaceGrade(name: String) -> String {

        for race in totalRaceData {
            if race.name == name {
                return race.grade
            }
        }

        return "unknown"
    }
    
    func getFinishedCountBy(raceNameList list: [String]) -> [String: Int] {
        // 각 클리어 레이스 카운트
        var finishedRaceCount = ["G1": 0, "G2": 0, "G3": 0]
        list.forEach { raceName in
            finishedRaceCount[self.getRaceGrade(name: raceName), default: 0] += 1
        }
        return finishedRaceCount
    }
    
    private func getRaceDataFromServer() {
        apiService.getRaceData { races in
            self.totalRaceData = races
            self.g1Races = self.getRaceByGrade(grade: "G1")
            self.g2Races = self.getRaceByGrade(grade: "G2")
            self.g3Races = self.getRaceByGrade(grade: "G3")
            self.raceChunksByTag = self.g1Races.chunked(into: 15) + self.g2Races.chunked(into: 15) + self.g3Races.chunked(into: 15)
            self.createTagRaceinfo()
        }
    }
    
    private func getRaceByGrade(grade: String) -> [Race] {
        return totalRaceData
            .filter { ($0.grade == grade) && $0.displayOrder > 0 }
            .sorted { ($0.grade, $0.displayOrder) < ($1.grade, $1.displayOrder) }
    }
    
    private func createTagRaceinfo() {
        let g1TagCount = ceil(Double(g1Races.count) / 15)
        let g2TagCount = ceil(Double(g2Races.count) / 15)
        let g3TagCount = ceil(Double(g3Races.count) / 15)
        tagRaceInfo.append(contentsOf: repeatElement("G1", count: Int(g1TagCount)))
        tagRaceInfo.append(contentsOf: repeatElement("G2", count: Int(g2TagCount)))
        tagRaceInfo.append(contentsOf: repeatElement("G3", count: Int(g3TagCount)))
    }
    
    func getRacesByPeriod(_ period: Period, isIncludeOP: Bool) -> [Race] {
        return getRacesByPeriod(year: period.year, month: period.month, isIncludeOP: isIncludeOP)
    }
    
    func getRacesByPeriod(year: Int, month: Float, isIncludeOP: Bool = false) -> [Race] {
        
        return totalRaceData.filter { race in
            let whole = Int(modf(month).0)
            let fraction = modf(month).1
            
            var yearCondition: Bool!
            var monthCondition: Bool!
            let gradeCondition: Bool = isIncludeOP ? true : (race.grade == "G1" || race.grade == "G2" || race.grade == "G3")
            
            switch year {
            case 1:
                yearCondition = race.period.contains("junior")
            case 2:
                yearCondition = race.period.contains("classic")
            case 3:
                yearCondition = race.period.contains("senior")
            default:
                break
            }
            
            let targetHalf = fraction == 0 ? "前半" : "後半"
            monthCondition = (race.month == whole && race.half == targetHalf)
            
            return yearCondition && monthCondition && gradeCondition
        }
    }
}
