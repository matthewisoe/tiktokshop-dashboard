//
//  SpendBarView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// SpendBarView.swift
// Single Responsibility: renders the spend vs GMV efficiency bar only.
// Visual representation of ROAS — one bar shows ad spend,
// the filled portion shows how much GMV that spend generated.
//
// Interview talking point:
//   "SpendBarView is a pure view — it takes two doubles and renders
//    a proportional bar. No business logic, no state. This follows
//    the Single Responsibility Principle — it does one thing well."

import SwiftUI

struct SpendBarView: View {

    let adSpend: Double
    let gmv: Double
    let color: Color

    // Efficiency ratio capped at 1.0 for bar width calculation
    // A ROAS of 5× means GMV is 5× spend — bar shows spend portion of GMV
    private var spendRatio: Double {
        guard gmv > 0 else { return 0 }
        return min(adSpend / gmv, 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {

            // Labels row
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text("Spend")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(shortFormat(adSpend))
                        .font(.caption2)
                        .fontWeight(.medium)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text(shortFormat(gmv))
                        .font(.caption2)
                        .fontWeight(.medium)
                    Text("GMV")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
            }

            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background — full GMV width
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.12))
                        .frame(height: 8)

                    // Foreground — ad spend portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.7))
                        .frame(
                            width: geo.size.width * CGFloat(spendRatio),
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.4), value: spendRatio)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Helpers
    private func shortFormat(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "%.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        }
        return String(format: "%.0f", value)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SpendBarView(
            adSpend: 4_679_612,
            gmv: 48_200_000,
            color: .blue
        )
        SpendBarView(
            adSpend: 60_125_000,
            gmv: 336_700_000,
            color: .purple
        )
    }
    .padding()
}