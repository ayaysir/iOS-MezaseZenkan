//
//  Musume.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/27.
//

import Foundation

/// This file was generated from JSON Schema using quicktype, do not modify it directly.
/// To parse the JSON, add this file to your project and do:
///
///  ```swift
///  let musume = try? newJSONDecoder().decode(Musume.self, from: jsonData)
///  ```
struct Musume: Codable {
    let name, nameEn, cv, birthday: String
    let height: Int
    let weight: String
    let b, w, h: Int
    let comment, catchphrase, imgProfile, imgDirectory: String
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case nameEn = "name_en"
        case cv, birthday, height, weight
        case b = "B"
        case w = "W"
        case h = "H"
        case comment, catchphrase
        case imgProfile = "img_profile"
        case isAvailable = "is_available"
        case imgDirectory = "img_directory"
    }
}
