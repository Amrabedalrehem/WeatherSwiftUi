//
//  WeatherDetailGridView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import SwiftUI

struct WeatherDetailGridView: View {
    
    let current: Current
    let fontColor: Color
    
    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            
            GridRow {
                GlassCardView {
                    DetailItemView(
                        title: "VISIBILITY",
                        value: "\(Int(current.vis_km)) km",
                        icon: "eye.fill",
                        fontColor: fontColor)
                }
                
                GlassCardView {
                    DetailItemView(
                        title: "HUMIDITY",
                        value: "\(current.humidity)%",
                        icon: "humidity.fill",
                        fontColor: fontColor
                    )
                }
            }
            GridRow {
                GlassCardView {
                    DetailItemView(
                        title: "FEELS LIKE",
                        value: "\(Int(current.feelslike_c))°",
                        icon: "thermometer.medium",
                        fontColor: fontColor)
                }
                
                GlassCardView {
                    DetailItemView(
                        title: "PRESSURE",
                        value: "\(Int(current.pressure_mb))",
                        icon: "gauge.medium",
                        fontColor: fontColor
                    )
                }
            }
        }
    }
}


