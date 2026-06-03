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
        content.padding(padding).background {
                RoundedRectangle(cornerRadius: cornerRadius).fill(.ultraThinMaterial).overlay {
                        RoundedRectangle(cornerRadius: cornerRadius).stroke(.white.opacity(0.3),
                                lineWidth: 1
                            )
                    }
            }
    }
}
