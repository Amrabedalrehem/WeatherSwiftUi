//
//  SwipeActionsModifier.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 06/06/2026.
//


import SwiftUI

struct SwipeActionsModifier: ViewModifier {
    var deleteAction: () -> Void
    var setHomeAction: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.clear)
                    .background(
                        HStack(spacing: 0) {
                            Color.blue.opacity(0.85)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        offset = 0
                                        isSwiped = false
                                    }
                                    setHomeAction()
                                }
                                .overlay(
                                    Image(systemName: "house.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 22, weight: .semibold))
                                )

                            Color.red.opacity(0.85)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        offset = 0
                                        isSwiped = false
                                    }
                                    deleteAction()
                                }
                                .overlay(
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 22, weight: .semibold))
                                )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .frame(width: max(-offset, 0))
            .clipped()

            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.width
                            if !isSwiped && translation < 0 {
                                offset = translation
                            } else if isSwiped {
                                offset = min(0, -140 + translation)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                if offset < -70 {
                                    offset = -140
                                    isSwiped = true
                                } else {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if isSwiped {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
                )
        }
    }
}