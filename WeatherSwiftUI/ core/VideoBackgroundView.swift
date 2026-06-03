//
//  VideoBackgroundView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//

import SwiftUI
import AVKit
 
enum WeatherVideo: String, CaseIterable {
    case sunny   = "sunny"
    case rainy   = "rainy"
    case thunder = "thunder"
    case snow    = "snow"
    case cloudy  = "cloudy"
    case night   = "night"
    var keywords: [String] {
        switch self {
        case .sunny:   return ["sunny", "clear"]
        case .rainy:   return ["rain", "drizzle", "shower", "sleet"]
        case .thunder: return ["thunder", "storm", "lightning"]
        case .snow:    return ["snow", "blizzard", "ice", "frost", "freezing"]
        case .cloudy:  return ["cloud", "overcast", "mist", "fog", "haze", "partly"]
        case .night:   return []
        }
    }

      static func from(condition: String, isDay: Bool) -> WeatherVideo {
           if !isDay {
            return .night
        }

        let conditionLower = condition.lowercased()
   for video in WeatherVideo.allCases where video != .night {
            if video.keywords.contains(where: { conditionLower.contains($0) }) {
                return video
            }
        }

          return isDay ? .sunny : .night
    }
}
 struct VideoBackgroundView: View {

    let condition: String
    let isDay: Bool

    private var video: WeatherVideo {
        WeatherVideo.from(condition: condition, isDay: isDay)
    }

    var body: some View {
        VideoLoopView(videoName: video.rawValue)
            .ignoresSafeArea()
    }
}
 struct VideoLoopView: UIViewRepresentable {

    let videoName: String

    func makeUIView(context: Context) -> PlayerContainerView {
        return PlayerContainerView()
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        guard uiView.currentVideoName != videoName else { return }
        uiView.updateVideo(named: videoName)
    }
}
class PlayerContainerView: UIView {

    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var gradientLayer: CAGradientLayer?
    private(set) var currentVideoName: String?

    init() {
        super.init(frame: .zero)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

      private func showFallbackGradient(for name: String) {
        gradientLayer?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        gradient.frame = bounds

        switch name {
        case "sunny":
            gradient.colors = [UIColor(red: 0.98, green: 0.75, blue: 0.20, alpha: 1).cgColor,
                               UIColor(red: 0.95, green: 0.55, blue: 0.10, alpha: 1).cgColor,
                               UIColor(red: 0.40, green: 0.70, blue: 0.95, alpha: 1).cgColor]
        case "cloudy":
            gradient.colors = [UIColor(red: 0.55, green: 0.60, blue: 0.70, alpha: 1).cgColor,
                               UIColor(red: 0.70, green: 0.75, blue: 0.82, alpha: 1).cgColor,
                               UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1).cgColor]
        case "rainy":
            gradient.colors = [UIColor(red: 0.15, green: 0.20, blue: 0.35, alpha: 1).cgColor,
                               UIColor(red: 0.30, green: 0.38, blue: 0.55, alpha: 1).cgColor,
                               UIColor(red: 0.45, green: 0.55, blue: 0.70, alpha: 1).cgColor]
        case "thunder":
            gradient.colors = [UIColor(red: 0.08, green: 0.08, blue: 0.15, alpha: 1).cgColor,
                               UIColor(red: 0.20, green: 0.18, blue: 0.30, alpha: 1).cgColor,
                               UIColor(red: 0.35, green: 0.32, blue: 0.45, alpha: 1).cgColor]
        case "snow":
            gradient.colors = [UIColor(red: 0.75, green: 0.85, blue: 0.95, alpha: 1).cgColor,
                               UIColor(red: 0.88, green: 0.92, blue: 0.97, alpha: 1).cgColor,
                               UIColor(red: 0.95, green: 0.97, blue: 1.00, alpha: 1).cgColor]
        case "night":
            gradient.colors = [UIColor(red: 0.03, green: 0.05, blue: 0.15, alpha: 1).cgColor,
                               UIColor(red: 0.08, green: 0.10, blue: 0.28, alpha: 1).cgColor,
                               UIColor(red: 0.12, green: 0.15, blue: 0.38, alpha: 1).cgColor]
        default:
            gradient.colors = [UIColor(red: 0.25, green: 0.50, blue: 0.80, alpha: 1).cgColor,
                               UIColor(red: 0.50, green: 0.75, blue: 0.95, alpha: 1).cgColor]
        }

        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        self.gradientLayer = gradient
        self.layer.insertSublayer(gradient, at: 0)
        self.currentVideoName = name
    }

    func updateVideo(named name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp4") else {
               showFallbackGradient(for: name)
            return
        }
        let url = URL(fileURLWithPath: path)

           let templateItem = AVPlayerItem(url: url)

          templateItem.preferredForwardBufferDuration = 5
          let oldLayer = playerLayer

        player?.pause()
        playerLooper = nil
        let queuePlayer = AVQueuePlayer()
        queuePlayer.actionAtItemEnd = .advance
        queuePlayer.automaticallyWaitsToMinimizeStalling = false

        self.player = queuePlayer
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: templateItem)
        let newLayer = AVPlayerLayer(player: queuePlayer)
        newLayer.videoGravity = .resizeAspectFill
        newLayer.frame = bounds
        newLayer.opacity = 0
        self.playerLayer = newLayer

        self.layer.addSublayer(newLayer)
        queuePlayer.play()
       CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        newLayer.opacity = 1
        oldLayer?.opacity = 0

        CATransaction.setCompletionBlock {
            oldLayer?.removeFromSuperlayer()
        }
        CATransaction.commit()

        self.currentVideoName = name
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        gradientLayer?.frame = bounds     }

    deinit {
        player?.pause()
        player = nil
        playerLooper = nil
    }
}

