//
//  UIImage+Ext.swift
//  Image2Video
//
//  Created by d.ishmukhametov on 11.03.2023.
//

import UIKit

extension UIImage {
  
  func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    cgImage?.pixelBuffer(width: width, height: height)
  }

  convenience init?(pixelBuffer: CVPixelBuffer) {
    
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
      return nil
    }
    
    self.init(cgImage: cgImage)
  }
}


extension CGImage {
  func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
         kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
    
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     width,
                                     height,
                                     kCVPixelFormatType_32ARGB,
                                     attrs as CFDictionary,
                                     &pixelBuffer)
    
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
      return nil
    }
    
    CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
    defer { CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0)) }
    
    let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
    
    context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
    
    return buffer
  }
  
}
