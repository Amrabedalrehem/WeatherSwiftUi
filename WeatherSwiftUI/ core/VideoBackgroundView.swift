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
    case cloudy  = " cloudy"
    case night   = "nigth"
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
    private(set) var currentVideoName: String?

    init() {
        super.init(frame: .zero)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateVideo(named name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp4") else { return }
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
    }

    deinit {
        player?.pause()
        player = nil
        playerLooper = nil
    }
}

