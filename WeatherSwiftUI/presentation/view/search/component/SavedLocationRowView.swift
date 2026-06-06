//
//  SavedLocationRowView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 02/06/2026.
//


import SwiftUI

struct SavedLocationRowView: View {
    
    let location: SavedLocation
    var fontColor: Color = .white
    
    var body: some View {
        GlassCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(fontColor)
                    
                    Text(location.country)
                        .font(.system(size: 14))
                        .foregroundColor(fontColor.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(fontColor.opacity(0.5))
            }
        }
    }
}