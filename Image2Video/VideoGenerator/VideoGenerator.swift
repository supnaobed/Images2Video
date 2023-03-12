//
//  VideoGenerator.swift
//  Image2Video
//
//  Created by d.ishmukhametov on 11.03.2023.
//

import AVKit
import MetalPetal

final class VideoGenerator {
  
  private let assetWriter: AVAssetWriter
  private let assetWriterInput: AVAssetWriterInput
  private let audioWriterInput: AVAssetWriterInput
  private let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
  private let context = try! MTIContext(device: MTLCreateSystemDefaultDevice()!)
  
  init(size: CGSize, outputURL: URL) throws {
    assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    let videoOutputSettings: [String : Any] = [
      AVVideoCodecKey : AVVideoCodecType.h264,
      AVVideoWidthKey : size.width,
      AVVideoHeightKey : size.height,
    ]
    assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
    assetWriterInput.expectsMediaDataInRealTime = true
    
    let audioSettings = [
      AVFormatIDKey: kAudioFormatMPEG4AAC,
      AVNumberOfChannelsKey: 2,
      AVSampleRateKey: 44100,
      AVEncoderBitRateKey: 128000
    ] as [String : Any]
    audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
    audioWriterInput.expectsMediaDataInRealTime = true
    
    
    let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
    self.pixelBufferAdaptor = pixelBufferAdaptor
    
    if assetWriter.canAdd(assetWriterInput) {
      assetWriter.add(assetWriterInput)
    }
    
    if assetWriter.canAdd(audioWriterInput) {
      assetWriter.add(audioWriterInput)
    }
    
    assetWriter.startWriting()
    assetWriter.startSession(atSourceTime: CMTime.zero)
  }
  
  func setAudio(asset: AVAsset, completion: @escaping () -> Void) {
    let audioTrack = asset.tracks(withMediaType: .audio)[0]
    let audioOutput = AVAssetReaderAudioMixOutput(audioTracks: [audioTrack], audioSettings: nil)
    let reader = try! AVAssetReader(asset: asset)
    reader.add(audioOutput)
    
    let queue = DispatchQueue(label: "assetWriterQueue")
    var isStartReading = false
    audioWriterInput.requestMediaDataWhenReady(on: queue) {
      while self.audioWriterInput.isReadyForMoreMediaData {
        if !isStartReading {
          reader.startReading()
          isStartReading = true
        }
        if let sampleBuffer = audioOutput.copyNextSampleBuffer() {
          self.audioWriterInput.append(sampleBuffer)
        } else {
          self.audioWriterInput.markAsFinished()
          completion()
          break
        }
      }
    }
    
  }
  
  func addImage(_ image: MTIImage, duration: TimeInterval) {
    
    let filteredImage = try! context.makeCGImage(from: image)
    
    let pixelBuffer = filteredImage.pixelBuffer(width: filteredImage.width, height: filteredImage.height)!
    let presentationTime = CMTime(seconds: duration, preferredTimescale: 10000)
    if assetWriterInput.isReadyForMoreMediaData {
      print(pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime))
    }
    
  }
  
  func finishWriting(completion: @escaping (URL?, Error?) -> Void) {
    assetWriterInput.markAsFinished()
    assetWriter.finishWriting {
      DispatchQueue.main.async {
        completion(self.assetWriter.outputURL, self.assetWriter.error)
      }
    }
  }
}
