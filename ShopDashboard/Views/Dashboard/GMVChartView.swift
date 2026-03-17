// GMVChartView.swift
// Single Responsibility: renders the 7-day GMV trend chart only.
// Uses Swift Charts (iOS 16+) — Apple's native charting framework.
//
// Performance note:
//   Chart data is computed once in the ViewModel (StatsService) and
//   passed in as a plain array. This view never does computation —
//   it only renders. Pure view = maximum re-render efficiency.

import SwiftUI
import Charts

struct GMVChartView: View {

    let trendData: [Double]   // 7 daily GMV values
    let brandColor: Color

    // Map raw doubles into chart-friendly structs
    private var chartPoints: [ChartPoint] {
        trendData.enumerated().map { index, value in
            ChartPoint(day: index, value: value)
        }
    }

    private var dayLabels: [String] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Section header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(brandColor)
                Text("7-Day GMV Trend")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(peakLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Chart
            Chart(chartPoints) { point in
                // Area gradient under the line
                AreaMark(
                    x: .value("Day", point.day),
                    y: .value("GMV", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [brandColor.opacity(0.3), brandColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                // Line
                LineMark(
                    x: .value("Day", point.day),
                    y: .value("GMV", point.value)
                )
                .foregroundStyle(brandColor)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)

                // Data point dots
                PointMark(
                    x: .value("Day", point.day),
                    y: .value("GMV", point.value)
                )
                .foregroundStyle(brandColor)
                .symbolSize(30)
            }
            .frame(height: 140)
            .chartXAxis {
                AxisMarks(values: Array(0..<7)) { value in
                    AxisValueLabel {
                        if let index = value.as(Int.self),
                           index < dayLabels.count {
                            Text(dayLabels[index])
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(shortFormat(v))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Helpers
    private var peakLabel: String {
        guard let peak = trendData.max() else { return "" }
        return "Peak: \(shortFormat(peak))"
    }

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

// MARK: - Chart data model
private struct ChartPoint: Identifiable {
    let id = UUID()
    let day: Int
    let value: Double
}

// MARK: - Preview
#Preview {
    GMVChartView(
        trendData: [38_000_000, 52_000_000, 48_000_000,
                    45_000_000, 51_000_000, 53_000_000, 49_700_000],
        brandColor: .blue
    )
    .padding()
}
