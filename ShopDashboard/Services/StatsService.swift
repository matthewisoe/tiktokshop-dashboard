// StatsService.swift
// Single Responsibility: aggregates SKU and Campaign data into DashboardStats.
// No fetching, no caching — only computation.
//
// Interview talking point:
//   "StatsService is purely functional — given the same inputs it always
//    returns the same output. This makes it trivial to unit test and means
//    the Dashboard view never needs to know how stats are calculated."

import Foundation

final class StatsService {

    // MARK: - Main aggregation
    // Called by AppState whenever brand filter or date range changes.
    func computeStats(from skus: [SKU], campaigns: [Campaign]) -> DashboardStats {
        let totalGMV      = skus.reduce(0) { $0 + $1.gmv7d }
        let totalOrders   = skus.reduce(0) { $0 + $1.orders7d }
        let totalAdSpend  = skus.reduce(0) { $0 + $1.adSpend7d }
        let averageROAS   = totalAdSpend > 0 ? totalGMV / totalAdSpend : 0

        return DashboardStats(
            totalGMV:      totalGMV,
            totalOrders:   totalOrders,
            averageROAS:   averageROAS,
            totalAdSpend:  totalAdSpend,
            gmvGrowth:     gmvGrowth(for: skus),
            ordersGrowth:  ordersGrowth(for: skus),
            roasGrowth:    roasGrowth(averageROAS: averageROAS),
            adSpendGrowth: adSpendGrowth(for: skus)
        )
    }

    // MARK: - 7-day trend data
    // Aggregates daily GMV across all SKUs into a single 7-point array.
    // Used by GMVChartView sparkline.
    func gmvTrend(from skus: [SKU]) -> [Double] {
        guard !skus.isEmpty else { return Array(repeating: 0, count: 7) }

        var trend = Array(repeating: 0.0, count: 7)
        for sku in skus {
            for (i, value) in sku.gmvTrend.enumerated() {
                if i < 7 { trend[i] += value }
            }
        }
        return trend
    }

    // MARK: - Brand breakdown
    // Used by Dashboard brand segment chart.
    func gmvByBrand(from skus: [SKU]) -> [(brand: Brand, gmv: Double)] {
        Brand.allCases.map { brand in
            let gmv = skus
                .filter { $0.brand == brand }
                .reduce(0) { $0 + $1.gmv7d }
            return (brand: brand, gmv: gmv)
        }
        .filter { $0.gmv > 0 }
        .sorted { $0.gmv > $1.gmv }
    }

    // MARK: - Alert summary
    func roasAlertSummary(from skus: [SKU]) -> (critical: Int, warning: Int, healthy: Int) {
        let critical = skus.filter { $0.roasAlert == .critical }.count
        let warning  = skus.filter { $0.roasAlert == .warning  }.count
        let healthy  = skus.filter { $0.roasAlert == .good     }.count
        return (critical, warning, healthy)
    }

    // MARK: - Top performer
    func topSKUByROAS(from skus: [SKU]) -> SKU? {
        skus.max { $0.roas < $1.roas }
    }

    func topSKUByGMV(from skus: [SKU]) -> SKU? {
        skus.max { $0.gmv7d < $1.gmv7d }
    }

    // MARK: - Private growth calculations
    // Hardcoded prior-period baseline from real internship data.
    // In production: fetch prior period from DB and compare dynamically.
    private func gmvGrowth(for skus: [SKU]) -> Double {
        let hasBBS = skus.contains { $0.brand == .baabaasheepz }
        return hasBBS ? 419.0 : 87.5
    }

    private func ordersGrowth(for skus: [SKU]) -> Double {
        let hasBBS = skus.contains { $0.brand == .baabaasheepz }
        return hasBBS ? 327.0 : 64.2
    }

    private func roasGrowth(averageROAS: Double) -> Double {
        // Baseline ROAS was ~4.2 prior period
        let baseline = 4.2
        guard baseline > 0 else { return 0 }
        return ((averageROAS - baseline) / baseline) * 100
    }

    private func adSpendGrowth(for skus: [SKU]) -> Double {
        8.5  // consistent across periods in internship data
    }
}
