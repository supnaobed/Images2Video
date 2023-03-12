//
//  ImageProcessor.swift
//  Image2Video
//
//  Created by d.ishmukhametov on 11.03.2023.
//

import UIKit
import CoreML

final class MaskProcessor {
  
  private lazy var model: Segmentation8bit? = {
    guard let model = try? Segmentation8bit() else {
      return nil
    }
    return model
  }()
  
  
  func processImage(_ image: UIImage) throws -> UIImage {
    guard let model else {
      throw ImageProcessorError.initializationProblem
    }
    
    guard let input = image.pixelBuffer(width: 1024, height: 1024) else {
      throw ImageProcessorError.invalidInput
    }
    
    let output = try model.prediction(img: input)
    
    guard let outputImage = UIImage(pixelBuffer: output.var_2274) else {
      throw ImageProcessorError.invalidOutput
    }
    return outputImage
  }
}

enum ImageProcessorError: Error {
  case invalidInput
  case invalidOutput
  case initializationProblem
}
