//
//  HourlyView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 01/06/2026.
//


import SwiftUI

struct HourlyView: View {
    
    let forecastDay: ForecastDay
    let fontColor: Color
        private var hoursFromNow: [Hour] {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dayFormatter.date(from: forecastDay.date) else {
            return forecastDay.hour
        }
        
        if Calendar.current.isDateInToday(date) {
            return forecastDay.hour.filter { hour in
                guard let hourDate = formatter.date(from: hour.time) else { return false }
                let hourComponent = Calendar.current.component(.hour, from: hourDate)
                return hourComponent >= currentHour
            }
        }
        return forecastDay.hour
    }
    
    var body: some View {
        ZStack {
                 VideoBackgroundView(
                condition: forecastDay.hour.first?.condition.text ?? "",
                isDay: true
            )
            
                  VStack(spacing: 0) {
                              HStack {
                    Text(dayLabel)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(fontColor)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
               
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(hoursFromNow, id: \.time) { hour in
                            GlassCardView {
                                HourRowView(
                                    hour: hour,
                                    fontColor: fontColor
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
 
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
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }
    }
}
 
