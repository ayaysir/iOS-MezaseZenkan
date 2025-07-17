//
//  String+Localized.swift
//  MezaseZenkan
//
//  Created by 윤범태 on 7/18/25.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
  }
  
  func localizedFormat(_ arguments: CVarArg...) -> String {
    let localizedValue = self.localized
    return String(format: localizedValue, arguments: arguments)
  }
}
