// SeedData.swift
// Real performance numbers from Hegen Indonesia, Oball Indonesia,
// and Baabaasheepz × Snoopy internship campaigns (2024-2025).
// Single Responsibility: data seeding only. No business logic here.

import Foundation

struct SeedData {

    // MARK: - Dashboard Stats
    // Aggregated across all 3 brands, reflecting actual internship results
    static let stats = DashboardStats(
        totalGMV:       702_500_000,   // IDR — combined across all brands
        totalOrders:    3_129,
        averageROAS:    5.3,
        totalAdSpend:   132_547_169,
        gmvGrowth:      419.0,         // Oball gross revenue growth vs prior period
        ordersGrowth:   327.0,         // Oball order growth
        roasGrowth:     12.0,
        adSpendGrowth:  8.5
    )

    // MARK: - SKUs
    static let skus: [SKU] = [

        // ── Hegen ────────────────────────────────────────────
        SKU(
            id: UUID(),
            name: "PPSU Wide-Neck Feeding Bottle 330ml",
            brand: .hegen,
            skuCode: "HGN-PPSU-330",
            priceIDR: 329_000,
            gmv7d: 48_200_000,
            orders7d: 146,
            roas: 10.3,
            adSpend7d: 4_679_612,
            conversionRate: 4.8,
            status: .active,
            gmvTrend: [5_200_000, 6_800_000, 7_100_000, 6_400_000,
                       7_900_000, 7_300_000, 7_500_000]
        ),
        SKU(
            id: UUID(),
            name: "PPSU Breast Milk Storage 150ml",
            brand: .hegen,
            skuCode: "HGN-STORE-150",
            priceIDR: 189_000,
            gmv7d: 12_400_000,
            orders7d: 65,
            roas: 3.8,
            adSpend7d: 3_263_157,
            conversionRate: 2.1,
            status: .paused,
            gmvTrend: [2_100_000, 1_900_000, 1_700_000, 1_600_000,
                       1_800_000, 1_600_000, 1_700_000]
        ),
        SKU(
            id: UUID(),
            name: "Electric Breast Pump Pro",
            brand: .hegen,
            skuCode: "HGN-PUMP-PRO",
            priceIDR: 1_899_000,
            gmv7d: 22_788_000,
            orders7d: 12,
            roas: 6.2,
            adSpend7d: 3_675_000,
            conversionRate: 1.4,
            status: .active,
            gmvTrend: [3_000_000, 3_200_000, 3_400_000, 3_100_000,
                       3_500_000, 3_288_000, 3_300_000]
        ),

        // ── Oball ─────────────────────────────────────────────
        SKU(
            id: UUID(),
            name: "Classic Ball",
            brand: .oball,
            skuCode: "OBL-CLASSIC-01",
            priceIDR: 89_000,
            gmv7d: 28_100_000,
            orders7d: 315,
            roas: 4.4,
            adSpend7d: 6_386_363,
            conversionRate: 3.2,
            status: .active,
            gmvTrend: [3_500_000, 3_800_000, 4_200_000, 4_100_000,
                       4_300_000, 4_100_000, 4_100_000]
        ),
        SKU(
            id: UUID(),
            name: "Flex & Grip Rattle",
            brand: .oball,
            skuCode: "OBL-RATTLE-02",
            priceIDR: 79_000,
            gmv7d: 21_300_000,
            orders7d: 269,
            roas: 5.1,
            adSpend7d: 4_176_470,
            conversionRate: 2.9,
            status: .active,
            gmvTrend: [2_800_000, 3_100_000, 3_200_000, 2_900_000,
                       3_100_000, 3_100_000, 3_100_000]
        ),
        SKU(
            id: UUID(),
            name: "Shaker Toy",
            brand: .oball,
            skuCode: "OBL-SHAKER-03",
            priceIDR: 69_000,
            gmv7d: 8_700_000,
            orders7d: 126,
            roas: 2.8,
            adSpend7d: 3_107_142,
            conversionRate: 1.8,
            status: .active,
            gmvTrend: [1_100_000, 1_200_000, 1_300_000, 1_200_000,
                       1_300_000, 1_300_000, 1_300_000]
        ),
        SKU(
            id: UUID(),
            name: "Go Grippers Car Set",
            brand: .oball,
            skuCode: "OBL-CAR-04",
            priceIDR: 119_000,
            gmv7d: 14_280_000,
            orders7d: 120,
            roas: 4.9,
            adSpend7d: 2_914_285,
            conversionRate: 2.4,
            status: .active,
            gmvTrend: [1_800_000, 2_000_000, 2_100_000, 2_000_000,
                       2_100_000, 2_100_000, 2_180_000]
        ),

        // ── Baabaasheepz ──────────────────────────────────────
        SKU(
            id: UUID(),
            name: "× Snoopy Plush Blanket",
            brand: .baabaasheepz,
            skuCode: "BBS-SNP-BLK-01",
            priceIDR: 259_000,
            gmv7d: 336_700_000,   // IDR 560M across Aug-Sep, 7d peak
            orders7d: 1_300,
            roas: 5.6,
            adSpend7d: 60_125_000,
            conversionRate: 6.1,
            status: .active,
            gmvTrend: [38_000_000, 52_000_000, 48_000_000, 45_000_000,
                       51_000_000, 53_000_000, 49_700_000]
        ),
        SKU(
            id: UUID(),
            name: "× Snoopy Plush Pillow",
            brand: .baabaasheepz,
            skuCode: "BBS-SNP-PLW-02",
            priceIDR: 199_000,
            gmv7d: 89_550_000,
            orders7d: 450,
            roas: 5.2,
            adSpend7d: 17_221_153,
            conversionRate: 5.4,
            status: .active,
            gmvTrend: [11_000_000, 13_000_000, 12_500_000, 12_000_000,
                       13_500_000, 13_550_000, 14_000_000]
        ),
        SKU(
            id: UUID(),
            name: "Classic Sherpa Blanket",
            brand: .baabaasheepz,
            skuCode: "BBS-SHERPA-01",
            priceIDR: 229_000,
            gmv7d: 18_320_000,
            orders7d: 80,
            roas: 3.1,
            adSpend7d: 5_909_677,
            conversionRate: 2.8,
            status: .active,
            gmvTrend: [2_400_000, 2_600_000, 2_700_000, 2_500_000,
                       2_700_000, 2_720_000, 2_700_000]
        ),
    ]

    // MARK: - Campaigns
    static let campaigns: [Campaign] = [

        // ── Hegen ────────────────────────────────────────────
        Campaign(
            id: UUID(),
            name: "Hegen All SKU GMV Max",
            brand: .hegen,
            type: .gmvMax,
            status: .running,
            adSpendIDR: 4_679_612,
            roas: 10.3,
            orders: 146,
            gmv: 48_200_000,
            impressions: 892_000,
            clicks: 24_100,
            startDate: date("2025-12-01")
        ),
        Campaign(
            id: UUID(),
            name: "Hegen Storage Discovery",
            brand: .hegen,
            type: .discovery,
            status: .paused,
            adSpendIDR: 3_263_157,
            roas: 3.8,
            orders: 65,
            gmv: 12_400_000,
            impressions: 430_000,
            clicks: 9_800,
            startDate: date("2025-12-05")
        ),

        // ── Oball ─────────────────────────────────────────────
        Campaign(
            id: UUID(),
            name: "Oball Classic GMV Max",
            brand: .oball,
            type: .gmvMax,
            status: .running,
            adSpendIDR: 6_386_363,
            roas: 4.4,
            orders: 315,
            gmv: 28_100_000,
            impressions: 1_240_000,
            clicks: 38_400,
            startDate: date("2025-12-01")
        ),
        Campaign(
            id: UUID(),
            name: "Oball Rattle Search Ads",
            brand: .oball,
            type: .search,
            status: .running,
            adSpendIDR: 4_176_470,
            roas: 5.1,
            orders: 269,
            gmv: 21_300_000,
            impressions: 680_000,
            clicks: 19_720,
            startDate: date("2025-12-03")
        ),
        Campaign(
            id: UUID(),
            name: "Oball Shaker Awareness",
            brand: .oball,
            type: .discovery,
            status: .running,
            adSpendIDR: 3_107_142,
            roas: 2.8,
            orders: 126,
            gmv: 8_700_000,
            impressions: 920_000,
            clicks: 18_400,
            startDate: date("2025-12-10")
        ),

        // ── Baabaasheepz ──────────────────────────────────────
        Campaign(
            id: UUID(),
            name: "BBS × Snoopy Grand Launch",
            brand: .baabaasheepz,
            type: .gmvMax,
            status: .running,
            adSpendIDR: 60_125_000,
            roas: 5.6,
            orders: 1_300,
            gmv: 336_700_000,
            impressions: 4_200_000,
            clicks: 126_000,
            startDate: date("2025-08-26")
        ),
        Campaign(
            id: UUID(),
            name: "BBS × Snoopy Pillow Search",
            brand: .baabaasheepz,
            type: .search,
            status: .running,
            adSpendIDR: 17_221_153,
            roas: 5.2,
            orders: 450,
            gmv: 89_550_000,
            impressions: 1_800_000,
            clicks: 54_000,
            startDate: date("2025-08-26")
        ),
        Campaign(
            id: UUID(),
            name: "BBS Sherpa Retargeting",
            brand: .baabaasheepz,
            type: .discovery,
            status: .running,
            adSpendIDR: 5_909_677,
            roas: 3.1,
            orders: 80,
            gmv: 18_320_000,
            impressions: 560_000,
            clicks: 11_200,
            startDate: date("2025-09-01")
        ),
    ]

    // MARK: - Date helper (private)
    private static func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }
}
