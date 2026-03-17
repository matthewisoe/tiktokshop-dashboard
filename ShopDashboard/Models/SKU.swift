// SKU.swift
// Single Responsibility: defines the SKU data model only.
// Equatable allows SwiftUI to skip re-rendering rows whose data hasn't changed
// — same concept as React.memo or memoization.

import Foundation

enum Brand: String, CaseIterable, Identifiable {
    case hegen       = "Hegen"
    case oball       = "Oball"
    case baabaasheepz = "Baabaasheepz"

    var id: String { rawValue }
}

enum SKUStatus: String {
    case active     = "Active"
    case paused     = "Paused"
    case outOfStock = "Out of Stock"
}

struct SKU: Identifiable, Equatable {
    let id: UUID
    let name: String
    let brand: Brand
    let skuCode: String
    let priceIDR: Double        // price in Indonesian Rupiah
    let gmv7d: Double           // 7-day GMV
    let orders7d: Int           // 7-day orders
    let roas: Double            // Return on Ad Spend
    let adSpend7d: Double       // 7-day ad spend
    let conversionRate: Double  // percentage
    let status: SKUStatus
    let gmvTrend: [Double]      // 7 daily GMV values for sparkline chart

    // ROAS threshold logic — used by DashboardView alert cards.
    // Single place to change the threshold (Open/Closed principle).
    var roasAlert: ROASAlert {
        switch roas {
        case 5.0...:  return .good
        case 3.0..<5: return .warning
        default:      return .critical
        }
    }

    enum ROASAlert {
        case good, warning, critical

        var label: String {
            switch self {
            case .good:     return "Healthy"
            case .warning:  return "Watch"
            case .critical: return "Critical"
            }
        }

        var colorName: String {
            switch self {
            case .good:     return "green"
            case .warning:  return "orange"
            case .critical: return "red"
            }
        }
    }

    // Equatable conformance — SwiftUI uses this to skip re-renders.
    // A SKURowView only redraws if its SKU value actually changed.
    static func == (lhs: SKU, rhs: SKU) -> Bool {
        lhs.id == rhs.id &&
        lhs.roas == rhs.roas &&
        lhs.gmv7d == rhs.gmv7d &&
        lhs.orders7d == rhs.orders7d &&
        lhs.status == rhs.status
    }
}
