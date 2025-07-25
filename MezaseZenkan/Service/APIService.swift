//
//  APIService.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/25.
//

import Foundation

class APIService {
  /// 레이스 데이터 JSON를 가져옴(일본판)
  // func getRaceData(completion : @escaping ([Race]) -> ()) {
  //   // let fileLocation = Bundle.main.url(forResource: "RaceData_20220819", withExtension: "json")
  //   let fileLocation = Bundle.main.url(forResource: "ko_RaceData_20250715", withExtension: "json")
  //   
  //   do {
  //     let data = try Data(contentsOf: fileLocation!)
  //     let array = try JSONDecoder().decode(Array<Race>.self, from: data)
  //     completion(array)
  //   } catch {
  //     print(error)
  //   }
  // }
  
  func getRaceData(from region: GameAppRegion, completion : @escaping ([Race]) -> ()) {
    let fileNamePrefix = region == .ko ? "ko" : "ja"
    
    let fileLocation = Bundle.main.url(forResource: "\(fileNamePrefix)_RaceData_20250715", withExtension: "json")
    
    do {
      let data = try Data(contentsOf: fileLocation!)
      let array = try JSONDecoder().decode(Array<Race>.self, from: data)
      completion(array)
    } catch {
      print(error)
    }
  }
  
  func getInitMusumeData(completion: @escaping ([Musume]) -> ()) {
    let fileName = SET_REAL_MUSUME_DATA ? "SampleMusumesData" : "Product-MusumeData"
    let fileLocation = Bundle.main.url(forResource: fileName, withExtension: "json")
    
    do {
      let data = try Data(contentsOf: fileLocation!)
      let array = try JSONDecoder().decode(Array<Musume>.self, from: data)
      completion(array)
    } catch {
      print(error)
    }
  }
  
  func loadMusumeData(completion: @escaping ([Musume]) -> ()) {
    do {
      let result = try UserDefaults.standard.getObject(forKey: "CURRENT_MUSUME_LIST", castTo: [Musume].self)
      completion(result)
    } catch let error as ObjectSavableError {
      if error == .noValue {
        getInitMusumeData(completion: completion)
      } else {
        print(#function, error.localizedDescription)
      }
    } catch {
      print(#function, error.localizedDescription)
    }
  }
  
  func saveMusumeData(musumes: [Musume]) {
    do {
      try UserDefaults.standard.setObject(musumes, forKey: "CURRENT_MUSUME_LIST")
    } catch {
      print(#function, error.localizedDescription)
    }
  }
  
  func loadStateData(completion : @escaping (RaceStates) -> ()) {
    let sampleStates: RaceStates = [
      "フユウララ": [:],
    ]
    
    if let receivedStates = UserDefaults.standard.object(forKey: "RACE_STATES") as? RaceStates {
      completion(receivedStates)
    } else {
      completion(sampleStates)
    }
  }
  
  func saveAllStatesData(states: RaceStates) {
    UserDefaults.standard.set(states, forKey: "RACE_STATES")
  }
  
  func loadCurrentMusumeName(completion : @escaping (String?) -> ()) {
    let musumeName = UserDefaults.standard.object(forKey: "CURRENT_MUSUME_NAME") as? String
    completion(musumeName)
  }
  
  func saveCurrentMusumeName(musume: Musume) {
    UserDefaults.standard.set(musume.name, forKey: "CURRENT_MUSUME_NAME")
  }
}

