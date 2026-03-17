//
//  DashboardView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// DashboardView.swift
// Main dashboard screen. Reads from AppState (global store) only —
// never fetches data directly. Pure rendering + user interaction.

import SwiftUI

struct DashboardView: View {

    @ObservedObject var state: AppState

    private var statsService: StatsService { StatsService() }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {

                    // Brand filter picker
                    brandPicker

                    // Alert banner — only shows if critical SKUs exist
                    if !state.alertSKUs.isEmpty {
                        alertBanner
                    }

                    // Stat cards grid
                    if let stats = state.stats {
                        statCardsGrid(stats: stats)
                    }

                    // GMV trend chart
                    GMVChartView(
                        trendData: statsService.gmvTrend(from: state.filteredSKUs),
                        brandColor: brandColor
                    )
                    .padding(.horizontal)

                    // Brand GMV breakdown
                    brandBreakdown

                }
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        state.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay {
                if state.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }

    // MARK: - Brand picker
    private var brandPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(state.brandOptions, id: \.?.rawValue) { brand in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            state.selectedBrand = brand
                        }
                    } label: {
                        Text(state.brandLabel(brand))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(state.selectedBrand == brand
                                          ? brandColor
                                          : Color.gray.opacity(0.12))
                            )
                            .foregroundColor(state.selectedBrand == brand
                                             ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Alert banner
    private var alertBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(state.alertSKUs.count) SKU\(state.alertSKUs.count > 1 ? "s" : "") need attention")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(alertSKUNames)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    // MARK: - Stat cards grid
    private func statCardsGrid(stats: DashboardStats) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            StatCardView(
                title: "Total GMV",
                value: stats.formattedGMV,
                growth: stats.gmvGrowth,
                icon: "chart.bar.fill",
                accentColor: brandColor
            )
            StatCardView(
                title: "Orders",
                value: stats.formattedOrders,
                growth: stats.ordersGrowth,
                icon: "bag.fill",
                accentColor: .purple
            )
            StatCardView(
                title: "Avg ROAS",
                value: stats.formattedROAS,
                growth: stats.roasGrowth,
                icon: "arrow.up.right.circle.fill",
                accentColor: .green
            )
            StatCardView(
                title: "Ad Spend",
                value: stats.formattedAdSpend,
                growth: stats.adSpendGrowth,
                icon: "dollarsign.circle.fill",
                accentColor: .orange
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Brand GMV breakdown
    private var brandBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GMV by Brand")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)

            let breakdown = statsService.gmvByBrand(from: state.filteredSKUs)
            let maxGMV = breakdown.map(\.gmv).max() ?? 1

            VStack(spacing: 10) {
                ForEach(breakdown, id: \.brand) { item in
                    HStack(spacing: 12) {
                        Text(item.brand.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(width: 100, alignment: .leading)

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorForBrand(item.brand))
                                .frame(
                                    width: geo.size.width * CGFloat(item.gmv / maxGMV),
                                    height: 20
                                )
                        }
                        .frame(height: 20)

                        Text(shortFormat(item.gmv))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 70, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers
    private var brandColor: Color {
        switch state.selectedBrand {
        case .hegen:        return .blue
        case .oball:        return .orange
        case .baabaasheepz: return .purple
        case nil:           return .blue
        }
    }

    private func colorForBrand(_ brand: Brand) -> Color {
        switch brand {
        case .hegen:        return .blue
        case .oball:        return .orange
        case .baabaasheepz: return .purple
        }
    }

    private var alertSKUNames: String {
        state.alertSKUs.prefix(3).map(\.name).joined(separator: ", ")
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
