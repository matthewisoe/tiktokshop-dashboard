// Campaign.swift
// Single Responsibility: defines the Campaign data model only.
// Equatable means CampaignRowView only redraws when data actually changes.

import Foundation

enum CampaignType: String {
    case gmvMax    = "GMV Max"
    case search    = "Search"
    case discovery = "Discovery"
}

enum CampaignStatus: String {
    case running = "Running"
    case paused  = "Paused"
    case ended   = "Ended"
}

struct Campaign: Identifiable, Equatable {
    let id: UUID
    let name: String
    let brand: Brand           // reuses Brand enum from SKU.swift
    let type: CampaignType
    let status: CampaignStatus
    let adSpendIDR: Double     // total spend in IDR
    let roas: Double
    let orders: Int
    let gmv: Double
    let impressions: Int
    let clicks: Int
    let startDate: Date

    // Computed — never stored, always derived from source values.
    // This is the Dependency Inversion principle: views depend on
    // this abstraction, not on raw impressions/clicks math.
    var ctr: Double {
        guard impressions > 0 else { return 0 }
        return (Double(clicks) / Double(impressions)) * 100
    }

    var spendEfficiency: Double {
        guard adSpendIDR > 0 else { return 0 }
        return gmv / adSpendIDR   // same as ROAS
    }

    // Spend efficiency thresholds — mirrors SKU.ROASAlert logic.
    var efficiencyAlert: EfficiencyAlert {
        switch roas {
        case 5.0...:  return .strong
        case 3.0..<5: return .moderate
        default:      return .weak
        }
    }

    enum EfficiencyAlert {
        case strong, moderate, weak

        var label: String {
            switch self {
            case .strong:   return "Strong"
            case .moderate: return "Moderate"
            case .weak:     return "Weak"
            }
        }

        var colorName: String {
            switch self {
            case .strong:   return "green"
            case .moderate: return "orange"
            case .weak:     return "red"
            }
        }
    }

    static func == (lhs: Campaign, rhs: Campaign) -> Bool {
        lhs.id == rhs.id &&
        lhs.roas == rhs.roas &&
        lhs.gmv == rhs.gmv &&
        lhs.status == rhs.status
    }
}
