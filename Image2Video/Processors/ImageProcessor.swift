//
//  ImageProcessor.swift
//  Image2Video
//
//  Created by d.ishmukhametov on 11.03.2023.
//

import UIKit
import MetalPetal

final class ImageProcessor {
  
  var maskProcessor: MaskProcessor
  var maskBlendProcessor: MaskBlendProcessor
  
  init(maskProcessor: MaskProcessor, maskBlendProcessor: MaskBlendProcessor) {
    self.maskProcessor = maskProcessor
    self.maskBlendProcessor = maskBlendProcessor
  }

  func processImage(_ inputImage: UIImage, with background: UIImage) throws -> MTIImage {
    let mask = try maskProcessor.processImage(inputImage)
    return try maskBlendProcessor.processImage(inputImage, with: mask, and: background)
  }
}
