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
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        guard let path = Bundle.main.path(
            forResource: videoName,
            ofType: "mp4"
        ) else {
            return view
        }
        
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(playerLayer)
 
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        player.play()
   
        context.coordinator.player = player
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
 
        guard let path = Bundle.main.path(
            forResource: videoName,
            ofType: "mp4"
        ) else { return }
        
        let url = URL(fileURLWithPath: path)
        let newItem = AVPlayerItem(url: url)
        context.coordinator.player?.replaceCurrentItem(with: newItem)
        context.coordinator.player?.play()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var player: AVPlayer?
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            player?.pause()
            player = nil
        }
    }
}
