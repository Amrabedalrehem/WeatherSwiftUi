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

    @Environment(\.dismiss) private var dismiss

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
        ZStack(alignment: .top) {
              VideoBackgroundView(
                condition: forecastDay.hour.first?.condition.text ?? "",
                isDay: true
            )
            .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

             VStack(spacing: 0) {
                HStack {
                       Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .frame(width: 90, alignment: .leading)

                    Spacer()

                      Text(dayLabel)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
             Color.clear
                        .frame(width: 90, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(hoursFromNow, id: \.time) { hour in
                            GlassCardView {
                                HourRowView(
                                    hour: hour,
                                    fontColor: .white
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
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
