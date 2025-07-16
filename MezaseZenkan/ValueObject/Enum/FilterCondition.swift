//
//  FilterCondition.swift
//  MezaseZenkan
//
//  Created by 윤범태 on 7/16/25.
//

import Foundation

enum FilterCondition: String {
  case junior, classic, senior, g1, g2, g3, grass, dirt,
       short, mile, intermediate, long,
       m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12,
       left, right, straight,
       firstHalf, secondHalf, reset, classicsenior,
       tokyo,
       nakayama,
       sapporo,
       oi,
       hanshin,
       kokura,
       kyoto,
       hakodate,
       fukushima,
       niigata,
       chukyou,
       kawasaki,
       funabashi,
       morioka,
       ronchamp,
       emptyPlace,
       emptyPlace2
}

extension FilterCondition {
  func regionDescription(of region: GameAppRegion) -> String {
    switch region {
    case .ja:
      regionJaDescription
    case .ko:
      regionKoDescription
    }
  }
  
  var regionJaDescription: String {
    switch self {
    case .grass: return "芝"
    case .dirt: return "ダート"
    case .short: return "短距離"
    case .mile: return "マイル"
    case .intermediate: return "中距離"
    case .long: return "長距離"
    case .left: return "左"
    case .right: return "右"
    case .straight: return "直線"
    case .firstHalf: return "前半"
    case .secondHalf: return "後半"
    case .tokyo: return "東京"
    case .nakayama: return "中山"
    case .sapporo: return "札幌"
    case .oi: return "大井"
    case .hanshin: return "阪神"
    case .kokura: return "小倉"
    case .kyoto: return "京都"
    case .hakodate: return "函館"
    case .fukushima: return "福島"
    case .niigata: return "新潟"
    case .chukyou: return "中京"
    case .kawasaki: return "川崎"
    case .funabashi: return "船橋"
    case .morioka: return "盛岡"
    case .ronchamp: return "ロンシャン"
    default: return self.rawValue
    }
  }
  
  var regionKoDescription: String {
    switch self {
    case .grass: "잔디"
    case .dirt: "더트"
    case .short: "단거리"
    case .mile: "마일"
    case .intermediate: "중거리"
    case .long: "장거리"
    case .left: "좌"
    case .right: "우"
    case .straight: "직선"
    case .firstHalf: "전반"
    case .secondHalf: "후반"
    case .tokyo: "도쿄"
    case .nakayama: "나카야마"
    case .sapporo: "삿포로"
    case .oi: "오이"
    case .hanshin: "한신"
    case .kokura: "코쿠라"
    case .kyoto: "교토"
    case .hakodate: "하코다테"
    case .fukushima: "후쿠시마"
    case .niigata: "니이가타"
    case .chukyou: "츄쿄"
    case .kawasaki: "가와사키"
    case .funabashi: "후나바시"
    case .morioka: "모리오카"
    case .ronchamp: "롱샹"
    default: self.rawValue
    }
  }
}
