//
//  CampaignRowView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// CampaignRowView.swift
// Single Responsibility: renders one campaign row only.
// Equatable — skips re-render if campaign data hasn't changed.

import SwiftUI

struct CampaignRowView: View, Equatable {

    let campaign: Campaign

    static func == (lhs: CampaignRowView, rhs: CampaignRowView) -> Bool {
        lhs.campaign == rhs.campaign
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Top row: name + status badge
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(campaign.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        // Brand tag
                        Text(campaign.brand.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(brandColor.opacity(0.12))
                            .foregroundColor(brandColor)
                            .cornerRadius(4)

                        // Campaign type tag
                        Text(campaign.type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.secondary)
                            .cornerRadius(4)
                    }
                }

                Spacer()

                // Status + ROAS
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(campaign.status.rawValue)
                            .font(.caption2)
                            .foregroundColor(statusColor)
                    }

                    Text(String(format: "%.1f× ROAS", campaign.roas))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(efficiencyColor)
                }
            }

            // Spend efficiency bar
            SpendBarView(
                adSpend: campaign.adSpendIDR,
                gmv: campaign.gmv,
                color: brandColor
            )

            // Bottom metrics row
            HStack {
                metricLabel("Orders", value: "\(campaign.orders)")
                Spacer()
                metricLabel("CTR", value: String(format: "%.2f%%", campaign.ctr))
                Spacer()
                metricLabel("GMV", value: shortFormat(campaign.gmv))
                Spacer()
                metricLabel("Spend", value: shortFormat(campaign.adSpendIDR))
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }

    // MARK: - Metric label helper
    private func metricLabel(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helpers
    private var brandColor: Color {
        switch campaign.brand {
        case .hegen:        return .blue
        case .oball:        return .orange
        case .baabaasheepz: return .purple
        }
    }

    private var statusColor: Color {
        switch campaign.status {
        case .running: return .green
        case .paused:  return .orange
        case .ended:   return .gray
        }
    }

    private var efficiencyColor: Color {
        switch campaign.efficiencyAlert {
        case .strong:   return .green
        case .moderate: return .orange
        case .weak:     return .red
        }
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

// MARK: - Preview
#Preview {
    CampaignRowView(campaign: SeedData.campaigns[0])
        .padding()
}