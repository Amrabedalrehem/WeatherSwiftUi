//
//  HourRowView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//

import SwiftUI

struct HourRowView: View {
    
    let hour: Hour
    let fontColor: Color
    
    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: hour.time) else {
            return hour.time
        }
        
        if Calendar.current.isDateInToday(date) {
            let currentHour = Calendar.current.component(.hour, from: Date())
            let hourComponent = Calendar.current.component(.hour, from: date)
            if hourComponent == currentHour {
                return "Now"
            }
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h a"
        return timeFormatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
                        Text(timeLabel)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(fontColor)
                .frame(width: 70, alignment: .leading)
            
            Spacer()
                   AsyncImage(url: URL(string: "https:\(hour.condition.icon)")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            Spacer()
            
        Text("\(Int(hour.temp_c))°")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(fontColor)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}
