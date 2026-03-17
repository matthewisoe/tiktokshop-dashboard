//
//  SKUDetailView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// SKUDetailView.swift
// Single Responsibility: renders full detail for one SKU.
// Navigated to from SKUListView — receives SKU by value (Equatable),
// so SwiftUI only redraws if the SKU actually changed.

import SwiftUI
import Charts

struct SKUDetailView: View {

    let sku: SKU

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {

                // Hero card
                heroCard

                // Key metrics grid
                metricsGrid

                // 7-day GMV sparkline
                GMVChartView(
                    trendData: sku.gmvTrend,
                    brandColor: brandColor
                )
                .padding(.horizontal)

                // Performance breakdown
                performanceCard

            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .navigationTitle(sku.skuCode)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero card
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sku.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(sku.brand.rawValue)
                        .font(.subheadline)
                        .foregroundColor(brandColor)
                }
                Spacer()
                // ROAS alert badge
                VStack(spacing: 4) {
                    Text(String(format: "%.1f×", sku.roas))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(roasColor)
                    Text("ROAS")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(roasColor.opacity(0.1))
                .cornerRadius(12)
            }

            Divider()

            HStack {
                Label(sku.status.rawValue, systemImage: statusIcon)
                    .font(.caption)
                    .foregroundColor(statusColor)
                Spacer()
                Text("SKU: \(sku.skuCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatIDR(sku.priceIDR))
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Metrics grid
    private var metricsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            metricCard(
                title: "7-Day GMV",
                value: shortFormat(sku.gmv7d),
                icon: "chart.bar.fill",
                color: brandColor
            )
            metricCard(
                title: "Orders",
                value: "\(sku.orders7d)",
                icon: "bag.fill",
                color: .purple
            )
            metricCard(
                title: "Ad Spend",
                value: shortFormat(sku.adSpend7d),
                icon: "dollarsign.circle.fill",
                color: .orange
            )
            metricCard(
                title: "Conv. Rate",
                value: String(format: "%.1f%%", sku.conversionRate),
                icon: "arrow.turn.up.right",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    private func metricCard(title: String, value: String,
                            icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }

    // MARK: - Performance breakdown
    private var performanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Performance Breakdown")
                .font(.subheadline)
                .fontWeight(.semibold)

            // ROAS gauge bar
            performanceRow(
                label: "ROAS",
                value: String(format: "%.1f×", sku.roas),
                fill: min(sku.roas / 10.0, 1.0),
                color: roasColor
            )

            // Conversion rate bar
            performanceRow(
                label: "Conv. Rate",
                value: String(format: "%.1f%%", sku.conversionRate),
                fill: min(sku.conversionRate / 10.0, 1.0),
                color: .blue
            )

            // ROAS alert status
            HStack {
                Circle()
                    .fill(roasColor)
                    .frame(width: 8, height: 8)
                Text("Status: \(sku.roasAlert.label)")
                    .font(.caption)
                    .foregroundColor(roasColor)
                Spacer()
                Text(roasAlertMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func performanceRow(label: String, value: String,
                                fill: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(fill), height: 6)
                        .animation(.easeInOut(duration: 0.5), value: fill)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Helpers
    private var brandColor: Color {
        switch sku.brand {
        case .hegen:        return .blue
        case .oball:        return .orange
        case .baabaasheepz: return .purple
        }
    }

    private var roasColor: Color {
        switch sku.roasAlert {
        case .good:     return .green
        case .warning:  return .orange
        case .critical: return .red
        }
    }

    private var statusColor: Color {
        switch sku.status {
        case .active:     return .green
        case .paused:     return .orange
        case .outOfStock: return .red
        }
    }

    private var statusIcon: String {
        switch sku.status {
        case .active:     return "checkmark.circle.fill"
        case .paused:     return "pause.circle.fill"
        case .outOfStock: return "xmark.circle.fill"
        }
    }

    private var roasAlertMessage: String {
        switch sku.roasAlert {
        case .good:     return "Performing well"
        case .warning:  return "Review ad strategy"
        case .critical: return "Pause or restructure"
        }
    }

    private func shortFormat(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "IDR %.1fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "IDR %.1fM", value / 1_000_000)
        }
        return String(format: "IDR %.0f", value)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        SKUDetailView(sku: SeedData.skus[0])
    }
}