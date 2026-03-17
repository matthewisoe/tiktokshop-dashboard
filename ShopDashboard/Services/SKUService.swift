// SKUService.swift
// Single Responsibility: fetches and caches SKU data only.
// Nothing else lives here — no campaign logic, no stats aggregation.
//
// Cache strategy:
//   1. Check LRUCache first (in-memory, O(1))
//   2. Cache hit  → return immediately, skip data fetch
//   3. Cache miss → fetch from SeedData (swap for CoreData/API later)
//              → store result in cache for next call
//
// Interview talking point:
//   "SKUService uses an LRU cache as the first layer. Cache hits are O(1)
//    and never touch the data layer. This is the same pattern as Redis
//    sitting in front of a database — the expensive operation only runs
//    on a cache miss."

import Foundation

final class SKUService {

    // MARK: - Cache
    // Keyed by brand name (or "all" for no filter).
    // Capacity 10 — more than enough for 3 brands + combinations.
    private let cache = LRUCache<String, [SKU]>(capacity: 10)

    // MARK: - Fetch
    func fetchSKUs(brand: Brand? = nil) -> [SKU] {
        let cacheKey = brand?.rawValue ?? "all"

        // Cache hit — return immediately
        if let cached = cache.get(cacheKey) {
            return cached
        }

        // Cache miss — fetch from data source
        // In production: replace SeedData with a CoreData fetch or API call
        let result: [SKU]
        if let brand = brand {
            result = SeedData.skus.filter { $0.brand == brand }
        } else {
            result = SeedData.skus
        }

        // Store in cache for next call
        cache.set(cacheKey, value: result)
        return result
    }

    // MARK: - Fetch single SKU by ID
    // Used by SKUDetailView — looks up from full list, no extra fetch
    func fetchSKU(id: UUID) -> SKU? {
        fetchSKUs().first { $0.id == id }
    }

    // MARK: - Sort
    // Sorting is a SKUService responsibility — views never sort directly
    func sorted(_ skus: [SKU], by order: SKUSortOrder) -> [SKU] {
        switch order {
        case .roasDesc:   return skus.sorted { $0.roas > $1.roas }
        case .roasAsc:    return skus.sorted { $0.roas < $1.roas }
        case .gmvDesc:    return skus.sorted { $0.gmv7d > $1.gmv7d }
        case .ordersDesc: return skus.sorted { $0.orders7d > $1.orders7d }
        case .spendDesc:  return skus.sorted { $0.adSpend7d > $1.adSpend7d }
        }
    }

    // MARK: - Alert filter
    // Returns only SKUs that need attention (ROAS below threshold)
    func alertSKUs(from skus: [SKU]) -> [SKU] {
        skus.filter { $0.roasAlert != .good }
    }

    // MARK: - Cache management
    func clearCache() {
        cache.clear()
    }

    var cacheSize: Int {
        cache.count
    }
}
