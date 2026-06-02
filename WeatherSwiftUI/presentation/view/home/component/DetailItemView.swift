//
//  DetailItemView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//

import SwiftUI
 
struct DetailItemView: View {
    
    let title: String
    let value: String
    let icon: String
    let fontColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(fontColor.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(fontColor.opacity(0.7))
            }
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(fontColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
