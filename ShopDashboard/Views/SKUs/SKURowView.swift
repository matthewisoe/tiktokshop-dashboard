//
//  SKURowView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// SKURowView.swift
// Single Responsibility: renders one SKU row only.
// Conforms to Equatable — SwiftUI skips re-rendering this row
// if the underlying SKU value hasn't changed (memoization).

import SwiftUI

struct SKURowView: View, Equatable {

    let sku: SKU

    // Equatable — row only redraws if SKU data actually changed
    static func == (lhs: SKURowView, rhs: SKURowView) -> Bool {
        lhs.sku == rhs.sku
    }

    var body: some View {
        HStack(spacing: 12) {

            // Brand color indicator bar
            RoundedRectangle(cornerRadius: 3)
                .fill(brandColor)
                .frame(width: 4, height: 52)

            // SKU info
            VStack(alignment: .leading, spacing: 4) {
                Text(sku.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(sku.brand.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(brandColor.opacity(0.12))
                        .foregroundColor(brandColor)
                        .cornerRadius(4)

                    Text(sku.skuCode)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    // Status badge
                    Text(sku.status.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.12))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
            }

            Spacer()

            // Metrics column
            VStack(alignment: .trailing, spacing: 4) {
                // ROAS with alert color
                HStack(spacing: 3) {
                    Circle()
                        .fill(roasAlertColor)
                        .frame(width: 6, height: 6)
                    Text(String(format: "%.1f×", sku.roas))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(roasAlertColor)
                }

                Text("ROAS")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(shortGMV)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }

    // MARK: - Helpers
    private var brandColor: Color {
        switch sku.brand {
        case .hegen:        return .blue
        case .oball:        return .orange
        case .baabaasheepz: return .purple
        }
    }

    private var roasAlertColor: Color {
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

    private var shortGMV: String {
        if sku.gmv7d >= 1_000_000_000 {
            return String(format: "IDR %.1fB", sku.gmv7d / 1_000_000_000)
        } else if sku.gmv7d >= 1_000_000 {
            return String(format: "IDR %.1fM", sku.gmv7d / 1_000_000)
        }
        return String(format: "IDR %.0f", sku.gmv7d)
    }
}

// MARK: - Preview
#Preview {
    SKURowView(sku: SeedData.skus[0])
        .padding()
}