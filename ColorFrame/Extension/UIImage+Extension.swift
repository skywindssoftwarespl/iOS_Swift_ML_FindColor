//
//  UIImage+Extension.swift
//  ColorFrame
//
//  Created by vidhi on 15/06/22.
//

import Foundation
import UIKit

extension UIImage {
    
    func convertImageToCGImage() -> CGImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return cgImage
        }
        
        return nil
    }
    
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
              return self
          }
          UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
          self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
          if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
              UIGraphicsEndImageContext()
              return normalizedImage
          } else {
              return self
          }
      }
    
    func resize(_ image: UIImage, imageViewHeight: CGFloat, imageWidth: CGFloat) -> UIImage {
        let actualHeight = Float(image.size.height)
        let actualWidth = Float(image.size.width)
        let maxHeight: Float = Float(imageViewHeight)
        let maxWidth: Float = Float(imageWidth)
        let _: Float = actualWidth / actualHeight
        let _: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(imageWidth), height: CGFloat(imageViewHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
}
