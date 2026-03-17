//
//  CampaignListView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// CampaignListView.swift
// Single Responsibility: renders the campaigns list screen only.
// LazyVStack ensures campaign rows only load when scrolled into view.

import SwiftUI

struct CampaignListView: View {

    @ObservedObject var state: AppState

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // Summary bar
                summaryBar

                // Campaign list
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if state.filteredCampaigns.isEmpty {
                            emptyState
                        } else {
                            ForEach(state.filteredCampaigns) { campaign in
                                CampaignRowView(campaign: campaign)
                                    .equatable()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Campaigns")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Summary bar
    private var summaryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {

                // Total spend
                summaryChip(
                    icon: "dollarsign.circle.fill",
                    label: "Total Spend",
                    value: shortFormat(totalSpend),
                    color: .orange
                )

                // Total GMV
                summaryChip(
                    icon: "chart.bar.fill",
                    label: "Total GMV",
                    value: shortFormat(totalGMV),
                    color: .blue
                )

                // Overall ROAS
                summaryChip(
                    icon: "arrow.up.right.circle.fill",
                    label: "Avg ROAS",
                    value: String(format: "%.1f×", overallROAS),
                    color: roasColor
                )

                // Running count
                summaryChip(
                    icon: "play.circle.fill",
                    label: "Running",
                    value: "\(runningCount)",
                    color: .green
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func summaryChip(icon: String, label: String,
                              value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No campaigns found")
                .font(.headline)
            Text("Try changing the brand filter")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Computed metrics
    private var totalSpend: Double {
        state.filteredCampaigns.reduce(0) { $0 + $1.adSpendIDR }
    }

    private var totalGMV: Double {
        state.filteredCampaigns.reduce(0) { $0 + $1.gmv }
    }

    private var overallROAS: Double {
        guard totalSpend > 0 else { return 0 }
        return totalGMV / totalSpend
    }

    private var runningCount: Int {
        state.filteredCampaigns.filter { $0.status == .running }.count
    }

    private var roasColor: Color {
        switch overallROAS {
        case 5.0...:  return .green
        case 3.0..<5: return .orange
        default:      return .red
        }
    }

    // MARK: - Format helper
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
    CampaignListView(state: AppState())
}