// AppState.swift
// The single source of truth for the entire app — equivalent to a Redux store.
//
// How it works:
//   - AppState is an ObservableObject with @Published properties
//   - Every view that needs data declares @ObservedObject var state: AppState
//   - When any @Published property changes, every subscribed view re-evaluates
//   - Only views whose inputs actually changed re-render (Equatable models stop the rest)
//
// Interview talking point:
//   "AppState is the SwiftUI equivalent of a Redux store. @Published properties
//    are like Redux state slices. Views subscribe like React components using
//    useSelector. The difference is SwiftUI's diffing engine handles re-render
//    optimisation automatically when models conform to Equatable."

import Foundation
import Combine

// MARK: - Sort Options
enum SKUSortOrder: String, CaseIterable {
    case roasDesc    = "ROAS ↓"
    case roasAsc     = "ROAS ↑"
    case gmvDesc     = "GMV ↓"
    case ordersDesc  = "Orders ↓"
    case spendDesc   = "Ad Spend ↓"
}

enum DateRange: String, CaseIterable {
    case last7Days  = "7 Days"
    case last30Days = "30 Days"
    case allTime    = "All Time"
}

// MARK: - AppState
final class AppState: ObservableObject {

    // MARK: - Published state
    // Any change to these triggers UI updates in subscribed views.

    @Published var selectedBrand: Brand? = nil      // nil = all brands
    @Published var dateRange: DateRange  = .last7Days
    @Published var skuSortOrder: SKUSortOrder = .roasDesc
    @Published var searchQuery: String   = ""
    @Published var isLoading: Bool       = false

    // MARK: - Data (set by services, never directly by views)
    @Published private(set) var allSKUs:      [SKU]            = []
    @Published private(set) var allCampaigns: [Campaign]       = []
    @Published private(set) var stats:        DashboardStats?  = nil

    // MARK: - Services (injected — Dependency Inversion Principle)
    private let skuService:      SKUService
    private let campaignService: CampaignService
    private let statsService:    StatsService

    // Combine cancellables — keeps subscriptions alive
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        skuService:      SKUService      = SKUService(),
        campaignService: CampaignService = CampaignService(),
        statsService:    StatsService    = StatsService()
    ) {
        self.skuService      = skuService
        self.campaignService = campaignService
        self.statsService    = statsService

        setupFilterPipeline()
        loadData()
    }

    // MARK: - Computed: filtered + sorted SKUs
    // Views always read filteredSKUs, never allSKUs directly.
    // Single place to change filter logic (Open/Closed Principle).
    var filteredSKUs: [SKU] {
        var result = allSKUs

        // Brand filter
        if let brand = selectedBrand {
            result = result.filter { $0.brand == brand }
        }

        // Search filter
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.skuCode.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        // Sort
        switch skuSortOrder {
        case .roasDesc:   result.sort { $0.roas > $1.roas }
        case .roasAsc:    result.sort { $0.roas < $1.roas }
        case .gmvDesc:    result.sort { $0.gmv7d > $1.gmv7d }
        case .ordersDesc: result.sort { $0.orders7d > $1.orders7d }
        case .spendDesc:  result.sort { $0.adSpend7d > $1.adSpend7d }
        }

        return result
    }

    // MARK: - Computed: filtered campaigns
    var filteredCampaigns: [Campaign] {
        var result = allCampaigns

        if let brand = selectedBrand {
            result = result.filter { $0.brand == brand }
        }

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        return result
    }

    // MARK: - Computed: alert SKUs (ROAS critical or warning)
    var alertSKUs: [SKU] {
        filteredSKUs.filter { $0.roasAlert != .good }
    }

    // MARK: - Computed: brand picker options
    var brandOptions: [Brand?] {
        [nil] + Brand.allCases   // nil = "All Brands"
    }

    func brandLabel(_ brand: Brand?) -> String {
        brand?.rawValue ?? "All Brands"
    }

    // MARK: - Data loading
    func loadData() {
        isLoading = true

        // In a real app these would be async API calls.
        // Using async/await pattern so this is easy to swap to real network calls.
        Task { @MainActor in
            self.allSKUs      = skuService.fetchSKUs()
            self.allCampaigns = campaignService.fetchCampaigns()
            self.stats        = statsService.computeStats(from: self.allSKUs,
                                                          campaigns: self.allCampaigns)
            self.isLoading    = false
        }
    }

    func refresh() {
        // Clear cache then reload — mirrors "pull to refresh" pattern
        skuService.clearCache()
        campaignService.clearCache()
        loadData()
    }

    // MARK: - Combine pipeline
    // When brand or dateRange changes, recompute stats automatically.
    // This is the reactive pattern — like RxJS/Redux-Observable.
    private func setupFilterPipeline() {
        Publishers.CombineLatest($selectedBrand, $dateRange)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                guard let self else { return }
                self.stats = self.statsService.computeStats(
                    from: self.filteredSKUs,
                    campaigns: self.filteredCampaigns
                )
            }
            .store(in: &cancellables)
    }
}
