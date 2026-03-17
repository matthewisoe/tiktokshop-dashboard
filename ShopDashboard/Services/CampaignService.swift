// CampaignService.swift
// Single Responsibility: fetches and caches Campaign data only.
// Mirrors SKUService pattern — same cache strategy, different data type.
//
// Interview talking point:
//   "Both SKUService and CampaignService follow the same interface pattern.
//    If I needed to swap mock data for a real TikTok Shop API, I'd only
//    change the fetch implementation inside each service — zero changes
//    to AppState or any view. That's the Open/Closed Principle."

import Foundation

final class CampaignService {

    // MARK: - Cache
    // Keyed by brand name or "all"
    private let cache = LRUCache<String, [Campaign]>(capacity: 10)

    // MARK: - Fetch all campaigns
    func fetchCampaigns(brand: Brand? = nil) -> [Campaign] {
        let cacheKey = brand?.rawValue ?? "all"

        // Cache hit
        if let cached = cache.get(cacheKey) {
            return cached
        }

        // Cache miss — fetch from data source
        let result: [Campaign]
        if let brand = brand {
            result = SeedData.campaigns.filter { $0.brand == brand }
        } else {
            result = SeedData.campaigns
        }

        cache.set(cacheKey, value: result)
        return result
    }

    // MARK: - Fetch single campaign by ID
    func fetchCampaign(id: UUID) -> Campaign? {
        fetchCampaigns().first { $0.id == id }
    }

    // MARK: - Filter by status
    func running(_ campaigns: [Campaign]) -> [Campaign] {
        campaigns.filter { $0.status == .running }
    }

    func paused(_ campaigns: [Campaign]) -> [Campaign] {
        campaigns.filter { $0.status == .paused }
    }

    // MARK: - Sort by spend efficiency (ROAS descending)
    func sortedByEfficiency(_ campaigns: [Campaign]) -> [Campaign] {
        campaigns.sorted { $0.roas > $1.roas }
    }

    // MARK: - Alert campaigns (ROAS below threshold)
    func weakCampaigns(_ campaigns: [Campaign]) -> [Campaign] {
        campaigns.filter { $0.efficiencyAlert == .weak }
    }

    // MARK: - Aggregate spend across campaigns
    func totalSpend(_ campaigns: [Campaign]) -> Double {
        campaigns.reduce(0) { $0 + $1.adSpendIDR }
    }

    func totalGMV(_ campaigns: [Campaign]) -> Double {
        campaigns.reduce(0) { $0 + $1.gmv }
    }

    // MARK: - Cache management
    func clearCache() {
        cache.clear()
    }

    var cacheSize: Int {
        cache.count
    }
}
