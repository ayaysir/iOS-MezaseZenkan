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
    
    init() {
        self.apiService =  APIService()
        getMusumeDataFromServer()
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
}
