import UIKit
import MetalPetal
import AVFoundation

class ViewController: UIViewController {
  
  private let imageNames = ["Untitled-2", "Untitled-3", "Untitled-4", "Untitled-5", "Untitled-6", "Untitled-7", "Untitled-8", "Untitled-9"]
  private lazy var images = imageNames.compactMap { UIImage(named: $0) }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    let player = AVPlayer()
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = view.bounds
    playerLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(playerLayer)
    
    guard let tempFileURL = makeTmpFile(),
          let audioURL = Bundle.main.url(forResource: "music", withExtension: "aac"),
          let videoGenerator = try? VideoGenerator(size: images.first!.size, outputURL: tempFileURL) else {
      return
    }
    
    let audio = AVAsset(url: audioURL)

    
    let blendedImages = zip(images, images.dropFirst()).compactMap { (first, second) in
      try? ImageProcessor(maskProcessor: MaskProcessor(), maskBlendProcessor: MaskBlendProcessor()).processImage(second, with: first)
    }
    
    var resultImages = [MTIImage]()
    
    for (originalImage, blendedImage) in zip(images, blendedImages) {
      resultImages.append(MTIImage(image: originalImage) )
      resultImages.append(blendedImage)
    }
    
    if let lastImage = images.last {
      resultImages.append( MTIImage(image: lastImage))
    }
    
    let frameDuration = audio.duration.seconds / Double(resultImages.count + 1)
    
    var time = frameDuration
    resultImages.forEach {
      videoGenerator.addImage($0, duration: time)
      time += frameDuration
    }
    
    videoGenerator.setAudio(asset: audio) {
      videoGenerator.finishWriting { url, error in
        guard let url = url else { return }
        player.replaceCurrentItem(with:  AVPlayerItem(url: url))
        player.play()
      }
    }
  }
  
  func makeTmpFile() -> URL? {
    let tempFilePath = NSTemporaryDirectory().appending("video.mp4")
    let tempFileURL = URL(fileURLWithPath: tempFilePath)
    
    do {
      if FileManager.default.fileExists(atPath: tempFilePath) {
        try FileManager.default.removeItem(atPath: tempFilePath)
      }
    } catch let error {
      print("Ошибка удаления временного файла: \(error.localizedDescription)")
    }
    print(tempFileURL)
    return tempFileURL
  }
}
