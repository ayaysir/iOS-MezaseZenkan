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
