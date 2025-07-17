//
//  ImageUtil.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/22.
//

import UIKit

extension UIImage {
  
  func withAlpha(_ a: CGFloat) -> UIImage {
    return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (_) in
      draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: a)
    }
  }
  
  // https://stackoverflow.com/questions/32836862
  func saveToDocuments(filename: String) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    if let data = self.pngData() {
      do {
        try data.write(to: fileURL)
      } catch {
        print("error saving file to documents:", error)
      }
    }
  }
}

func grayscale(image: UIImage, filterName: String = "CIPhotoEffectNoir") -> UIImage? {
  let context = CIContext(options: nil)
  if let filter = CIFilter(name: filterName) {
    filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
    if let output = filter.outputImage {
      if let cgImage = context.createCGImage(output, from: output.extent) {
        return UIImage(cgImage: cgImage)
      }
    }
  }
  
  return nil
}

func convertToGrayScale(image: UIImage) -> UIImage? {
  let imageRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
  let colorSpace = CGColorSpaceCreateDeviceGray()
  let width = image.size.width
  let height = image.size.height
  let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
  let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
  
  if let cgImg = image.cgImage {
    context?.draw(cgImg, in: imageRect)
    if let makeImg = context?.makeImage() {
      let imageRef = makeImg
      let newImage = UIImage(cgImage: imageRef)
      return newImage
    }
  }
  
  return UIImage()
}

// https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, textFont: UIFont) -> UIImage {
  let textColor = UIColor.white
  //    let textFont = UIFont(name: "Helvetica Bold", size: 40)!
  
  let scale = UIScreen.main.scale
  UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
  
  let paragraphStyle = NSMutableParagraphStyle()
  
  paragraphStyle.alignment = .center
  let textFontAttributes: [NSAttributedString.Key: Any] = [
    .font: textFont,
    .foregroundColor: textColor,
    .paragraphStyle: paragraphStyle
  ]
  
  image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
  
  let rect = CGRect(origin: point, size: image.size)
  text.draw(in: rect, withAttributes: textFontAttributes)
  
  let newImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return newImage!
}

func raceToBanner(race: Race) -> UIImage {
  let bannerURL = race.grade == "OP" || race.grade == "Pre-OP" ? "ProductImages/OP-Banner.png" : "ProductImages/\(race.grade)-Banner.png"
  
  let blankBanner = UIImage(named: bannerURL)!
  let textFont = UIFont(name: "Helvetica Bold", size: 40)!
  let yPos = race.name.count <= 8 ? (blankBanner.size.height - textFont.lineHeight) / 2 : blankBanner.size.height / 2 - textFont.lineHeight
  let point = CGPoint(x: 0, y: yPos)
  return textToImage(drawText: race.name, inImage: blankBanner, atPoint: point, textFont: textFont)
}

func deleteFile(named fileName: String) {
  let fileManager = FileManager.default

  // Document 디렉토리 경로 구하기
  if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
    let fileURL = documentsDirectory.appendingPathComponent(fileName)

    if fileManager.fileExists(atPath: fileURL.path) {
      do {
        try fileManager.removeItem(at: fileURL)
        print("\(fileName) 삭제 완료")
      } catch {
        print("파일 삭제 실패: \(error)")
      }
    } else {
      print("파일이 존재하지 않음: \(fileName)")
    }
  }
}
