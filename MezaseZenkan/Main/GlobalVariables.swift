//
//  GlobalVariables.swift
//  MezaseZenkan
//
//  Created by 윤범태 on 7/16/25.
//

import UIKit

// MARK: - Type Aliases

typealias RaceStates = [String: [String: Bool]]

// MARK: - Global Variables

let store = UserDefaults.standard
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let osVersion = UIDevice.current.systemVersion
