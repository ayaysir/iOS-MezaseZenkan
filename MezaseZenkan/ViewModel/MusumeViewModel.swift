//
//  MusumeViewModel.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/27.
//

import Foundation

class MusumeViewModel {
    
    private var apiService: APIService!
    private var totalMusumeData: [Musume]! {
        didSet {
            
        }
    }
    
    var currentMusume: Musume! {
        didSet {
            apiService.saveCurrentMusumeName(musume: currentMusume)
        }
    }
    
    init() {
        self.apiService =  APIService()
        getMusumeDataFromServer()
        
        // Select a musume
        apiService.loadCurrentMusumeName { [self] musumeName in
            if let musumeName = musumeName {
                currentMusume = getMusumeBy(name: musumeName) ?? getMusumeBy(index: 0)
            } else {
                currentMusume = getMusumeBy(index: 0)
            }
        }
    }
    
    var totalCount: Int {
        return totalMusumeData.count
    }
    
    
    private func getMusumeDataFromServer() {
        apiService.getMusumeData { musumes in
            self.totalMusumeData = musumes
        }
    }
    
    func printAllData() {
        print(totalMusumeData ?? "none")
    }
    
    func getMusumeBy(index: Int) -> Musume {
        return totalMusumeData[index]
    }
    
    func getMusumeBy(name: String) -> Musume? {
        return totalMusumeData.first { $0.name == name }
    }
}
