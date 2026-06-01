//
//  VideoBackgroundView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//

 
import SwiftUI
import AVKit

struct VideoBackgroundView: View {
    
    let condition: String
    let isDay: Bool
    
    private var videoName: String {
        let conditionLower = condition.lowercased()
        
        if !isDay {
            return "night"
        }
        
        if conditionLower.contains("sunny") ||
           conditionLower.contains("clear") {
            return "sunny"
        } else if conditionLower.contains("rain") ||
                  conditionLower.contains("drizzle") {
            return "rainy"
        } else if conditionLower.contains("thunder") ||
                  conditionLower.contains("storm") {
            return "thunder"
        } else if conditionLower.contains("snow") ||
                  conditionLower.contains("blizzard") {
            return "snow"
        } else if conditionLower.contains("cloud") ||
                  conditionLower.contains("overcast") {
            return "cloudy"
        } else {
            return isDay ? "sunny" : "night"
        }
    }
    
    var body: some View {
        VideoLoopView(videoName: videoName)
            .ignoresSafeArea()
    }
}

struct VideoLoopView: UIViewRepresentable {
    
    let videoName: String
    
    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        return view
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
        let playerItem = AVPlayerItem(url: url)
        
           player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLooper = nil
        
              let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.player = queuePlayer
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        let layer = AVPlayerLayer(player: queuePlayer)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.playerLayer = layer
        
        self.layer.addSublayer(layer)
        queuePlayer.play()
        
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
