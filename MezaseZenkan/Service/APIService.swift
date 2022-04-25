//
//  APIService.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/25.
//

import Foundation

class APIService {
    
    func getRaceData(completion : @escaping ([Race]) -> ()) {
        
        let fileLocation = Bundle.main.url(forResource: "SampleData", withExtension: "json")
        
        do {
            let data = try Data(contentsOf: fileLocation!)
            let array = try JSONDecoder().decode(Array<Race>.self, from: data)
            completion(array)
        } catch {
            print(error)
        }
    }
    
    func getStateData(completion : @escaping (RaceStates) -> ()) {
        
        do {
            let sampleStates: RaceStates = [
                "ハルウララ": [:],
                "ナイスネイチャ": [:],
                "ニシノフラワー": [:],
             ]
            
            let receivedStates = UserDefaults.standard.object(forKey: "RACE_STATES") as? RaceStates
            if let states = receivedStates {
                completion(states)
            } else {
                completion(sampleStates)
            }
            
        } catch {
            print(error)
        }
    }
    
    func setAllStatesData(states: RaceStates) {
        UserDefaults.standard.set(states, forKey: "RACE_STATES")
    }
}
