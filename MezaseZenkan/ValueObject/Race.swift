//
//  Race.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/21.
//

import Foundation

struct Race: Codable {
  let period: String
  let month: Int
  let half, name, nameShort, grade: String
  let place, terrain: String
  let length: Int
  let lengthType, direction: String
  let displayOrder: Int
  let gamewithPostid: Int
  let bannerURL: String
  
  enum CodingKeys: String, CodingKey {
    case period, month, half, name
    case nameShort = "name_short"
    case grade, place, terrain, length
    case lengthType = "length_type"
    case direction
    case displayOrder = "display_order"
    case gamewithPostid = "gamewith_postid"
    case bannerURL = "banner_url"
  }
}
