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
      apiService.saveMusumeData(musumes: totalMusumeData)
    }
  }
  private(set) var currentRegion: String? = nil
  
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
    apiService.loadMusumeData { musumes in
      // print(musumes)
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
  
  func isNameDuplicated(name: String) -> Bool {
    return totalMusumeData.contains { musume in
      musume.name == name
    }
  }
  
  func addMusume(_ musume: Musume) {
    totalMusumeData.append(musume)
  }
  
  /// Musume 삭제
  /// - totalMusumeData가 갱신되면 UserDefaults에 자동 저장
  func removeMusume(_ musumes: [Musume]) {
    let musumesToRemove = Set(musumes)
    totalMusumeData = totalMusumeData.filter { !musumesToRemove.contains($0) }
  }
  
  /// Musume 삭제 (index로)
  /// - totalMusumeData가 갱신되면 UserDefaults에 자동 저장
  func removeMusume(by indexes: Set<Int>) {
    guard var localTotalMusumeData = totalMusumeData else {
      return
    }
    // 인덱스를 오름차순으로 정렬한 후 뒤에서부터 삭제해야 index 오류 방지됨
    let sortedIndexes = indexes.sorted(by: >)
    
    for index in sortedIndexes {
      guard localTotalMusumeData.indices.contains(index) else { continue }
      localTotalMusumeData.remove(at: index)
    }
    
    self.totalMusumeData = localTotalMusumeData
  }
  
  /// Musume 업데이트
  /// - totalMusumeData 배열에서 기존 무스메를 인덱스로 찾아 교체
  func updateMusume(_ musume: Musume, replaceTo index: Int) {
    guard index >= 0 && index < totalMusumeData.count else { return }
    totalMusumeData[index] = musume
  }
  
  /// Musume의 인덱스 반환
  func findIndex(of musume: Musume) -> Int? {
    totalMusumeData.firstIndex(where: { $0 == musume })
  }
}
