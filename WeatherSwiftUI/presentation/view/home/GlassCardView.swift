//
//  GlassCardView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//
 
import SwiftUI

struct GlassCardView<Content: View>: View {
    
    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    
    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.13))
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.55), .white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            }
    }
}
