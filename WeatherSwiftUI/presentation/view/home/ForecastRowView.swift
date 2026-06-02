//
//  ForecastRowView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import SwiftUI

struct ForecastRowView: View {
    
    let forecastDay: ForecastDay
    let fontColor: Color
    
     private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: forecastDay.date) else {
            return forecastDay.date
        }
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            return dayFormatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
              Text(dayLabel)
                .font(.system(size: 16, weight: .medium)).foregroundColor(fontColor).frame(width: 90, alignment: .leading)
            
            Spacer()
             AsyncImage(url: URL(string: "https:\(forecastDay.day.condition.icon)")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            Spacer()
                 Text("\(Int(forecastDay.day.mintemp_c))° - \(Int(forecastDay.day.maxtemp_c))°").font(.system(size: 16, weight: .medium))
                .foregroundColor(fontColor).frame(width: 90, alignment: .trailing)
        }.padding(.vertical, 8)
    }
}
