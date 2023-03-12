//
//  MaskProcessor.swift
//  Image2Video
//
//  Created by d.ishmukhametov on 11.03.2023.
//

import UIKit
import MetalPetal
import MetalKit

final class MaskBlendProcessor {
  
  func processImage(_ inputImage: UIImage, with maskImage: UIImage, and background: UIImage) throws -> MTIImage {

    
    let blurFilter = MTIMPSGaussianBlurFilter()
    blurFilter.radius = 5
    blurFilter.inputImage = MTIImage(image: maskImage, isOpaque: true)
   
    guard let maskMTIImage =  blurFilter.outputImage else {
      throw ImageProcessorError.invalidInput
    }
    
    let inputMTIImage = MTIImage(image: inputImage, isOpaque: true)
    let inputBackgroundImage = MTIImage(image: background, isOpaque: true)
    
    
    let blendFilter = MTIBlendWithMaskFilter()
    blendFilter.inputMask = MTIMask(content: maskMTIImage)
    blendFilter.inputBackgroundImage = inputBackgroundImage
    blendFilter.inputImage = inputMTIImage
    
    
    guard let outputImage = blendFilter.outputImage else {
      throw ImageProcessorError.invalidOutput
    }
    return outputImage
  }
}
