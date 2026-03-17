// DashboardStats.swift
// Single Responsibility: aggregated stats model for the Dashboard screen only.
// Keeping this separate means StatsService can change how it calculates
// without touching any view code (Dependency Inversion Principle).

import Foundation

struct DashboardStats: Equatable {
    let totalGMV: Double
    let totalOrders: Int
    let averageROAS: Double
    let totalAdSpend: Double

    // Growth percentages vs prior period — real numbers from Hegen/Oball internship
    let gmvGrowth: Double
    let ordersGrowth: Double
    let roasGrowth: Double
    let adSpendGrowth: Double

    // Computed helpers — views use these, never raw math
    var formattedGMV: String {
        formatIDR(totalGMV)
    }

    var formattedAdSpend: String {
        formatIDR(totalAdSpend)
    }

    var formattedROAS: String {
        String(format: "%.1f×", averageROAS)
    }

    var formattedOrders: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalOrders)) ?? "\(totalOrders)"
    }

    // Growth badge helper — used by StatCardView
    func growthLabel(_ value: Double) -> String {
        value >= 0 ? "+\(String(format: "%.1f", value))%" : "\(String(format: "%.1f", value))%"
    }

    func growthIsPositive(_ value: Double) -> Bool {
        value >= 0
    }
}

// MARK: - Shared formatting helper
// Defined once here, used across models — DRY principle.
func formatIDR(_ value: Double) -> String {
    if value >= 1_000_000_000 {
        return String(format: "IDR %.1fB", value / 1_000_000_000)
    } else if value >= 1_000_000 {
        return String(format: "IDR %.1fM", value / 1_000_000)
    } else {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "IDR \(formatter.string(from: NSNumber(value: value)) ?? "\(value)")"
    }
}
