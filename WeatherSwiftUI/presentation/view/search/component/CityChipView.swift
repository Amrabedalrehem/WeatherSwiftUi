//
//  CityChipView.swift
//  WeatherSwiftUI
//
//  Created by JETSMobileLabMini2 on 05/06/2026.
//

import SwiftUI

struct CityChipView: View {
    let city: SavedLocation
    let delay: Double
    let animate: Bool
    var fontColor: Color = .white

    private var flagEmoji: String {
        let country = city.country.lowercased()
        let flags: [String: String] = [
            "egypt": "🇪🇬", "morocco": "🇲🇦", "nigeria": "🇳🇬",
            "kenya": "🇰🇪", "south africa": "🇿🇦", "tunisia": "🇹🇳",
            "united arab emirates": "🇦🇪", "saudi arabia": "🇸🇦",
            "kuwait": "🇰🇼", "qatar": "🇶🇦", "lebanon": "🇱🇧",
            "jordan": "🇯🇴", "iraq": "🇮🇶", "oman": "🇴🇲",
            "united kingdom": "🇬🇧", "france": "🇫🇷", "germany": "🇩🇪",
            "italy": "🇮🇹", "spain": "🇪🇸", "netherlands": "🇳🇱",
            "austria": "🇦🇹", "turkey": "🇹🇷", "russia": "🇷🇺",
            "japan": "🇯🇵", "china": "🇨🇳", "south korea": "🇰🇷",
            "singapore": "🇸🇬", "thailand": "🇹🇭", "india": "🇮🇳",
            "pakistan": "🇵🇰", "bangladesh": "🇧🇩",
            "united states": "🇺🇸", "canada": "🇨🇦", "mexico": "🇲🇽",
            "brazil": "🇧🇷", "argentina": "🇦🇷",
            "australia": "🇦🇺"
        ]
        return flags[country] ?? "🌍"
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(flagEmoji)
                .font(.system(size: 16))
            Text(city.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(fontColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
        .scaleEffect(animate ? 1 : 0.85)
        .opacity(animate ? 1 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7).delay(delay),
            value: animate
        )
    }
}
