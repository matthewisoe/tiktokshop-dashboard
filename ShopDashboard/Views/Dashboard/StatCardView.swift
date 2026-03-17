// StatCardView.swift
// Single Responsibility: renders one stat card only.
// Equatable conformance means this view only redraws when its
// specific stat actually changes — memoization at the view level.
//
// Interview talking point:
//   "StatCardView conforms to Equatable. SwiftUI's diffing engine
//    compares old and new values before re-rendering. If nothing changed,
//    the view is skipped entirely — same concept as React.memo()."

import SwiftUI

struct StatCardView: View, Equatable {

    let title: String
    let value: String
    let growth: Double
    let icon: String
    let accentColor: Color

    // Equatable — SwiftUI skips re-render if these haven't changed
    static func == (lhs: StatCardView, rhs: StatCardView) -> Bool {
        lhs.value == rhs.value && lhs.growth == rhs.growth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Header row
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }

            // Main value
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // Growth badge
            HStack(spacing: 4) {
                Image(systemName: growth >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2)
                Text(growthLabel)
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(growth >= 0 ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(growth >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Private helpers
    private var growthLabel: String {
        growth >= 0
            ? "+\(String(format: "%.1f", growth))% vs prior"
            : "\(String(format: "%.1f", growth))% vs prior"
    }
}

// MARK: - Preview
#Preview {
    HStack {
        StatCardView(
            title: "Total GMV",
            value: "IDR 702.5M",
            growth: 419.0,
            icon: "chart.bar.fill",
            accentColor: .blue
        )
        StatCardView(
            title: "Avg ROAS",
            value: "5.3×",
            growth: 12.0,
            icon: "arrow.up.right.circle.fill",
            accentColor: .green
        )
    }
    .padding()
}
