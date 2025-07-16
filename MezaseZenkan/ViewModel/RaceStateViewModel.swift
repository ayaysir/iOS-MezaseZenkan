//
//  RaceStateViewModel.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/26.
//

import Foundation

class RaceStateViewModel {
  /*
   var finishedRaceCount: [String: Int] = ["G1": 0, "G2": 0, "G3": 0]
   
   var sampleCurrentMusume: String = "ハルウララ"
   var sampleMusumeAndFinishedRace: [String: [String: Bool]] = [
   "ハルウララ": ["ホープフルステークス": true, "安田記念": true, "札幌記念": true]
   ]
   var sampleFinishedRace: [String: Bool] = ["ホープフルステークス": true, "安田記念": true, "札幌記念": true, "武蔵野ステークス": true]
   */
  
  private var apiService: APIService!
  private var raceStateData: RaceStates! {
    didSet {
      apiService.saveAllStatesData(states: raceStateData)
    }
  }
  
  init() {
    self.apiService = APIService()
    getStateDataFromServer()
  }
  
  private func getStateDataFromServer() {
    apiService.loadStateData { states in
      self.raceStateData = states
    }
  }
  
  private func setStateDataToServer() { }
  
  func getTotalFinishedRaceCountBy(musumeName: String) -> Int? {
    return raceStateData[musumeName]?.filter { (raceName: String, finished: Bool) in
      finished
    }.count
  }
  
  func getFinishedRaceNamesBy(musumeName: String) -> [String] {
    
    let keys = raceStateData[musumeName]?.filter { (raceName: String, finished: Bool) in
      finished
    }.keys
    
    if let keys = keys {
      return Array(keys)
    } else {
      return []
    }
  }
  
  func getFinishedBy(musumeName: String, raceName: String) -> Bool {
    if let musume = raceStateData[musumeName] {
      return musume[raceName] ?? false
    }
    return false
  }
  
  func setFinish(musumeName: String, raceName: String, isFinished: Bool) {
    raceStateData[musumeName, default: [String: Bool]()][raceName] = isFinished
  }
  
  func toggleFinishResult(musumeName: String, raceName: String) {
    let prevFinishResult = self.getFinishedBy(musumeName: musumeName, raceName: raceName)
    self.setFinish(musumeName: musumeName, raceName: raceName, isFinished: !prevFinishResult)
  }
}
