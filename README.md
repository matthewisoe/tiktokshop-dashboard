# TikTok Shop Seller Dashboard — iOS App

> Built with SwiftUI · Global State Management · LRU Cache · SOLID Architecture

A native iOS seller operations dashboard built from real experience managing **5 TikTok Shop accounts** across Hegen Indonesia, Oball Indonesia, and Baabaasheepz × Snoopy — brands that collectively generated **IDR 702.5M+ GMV** with sustained **ROAS >5×**.

This isn't a tutorial app. It replicates the actual daily workflow an operator runs every morning: which SKUs are underperforming ROAS thresholds, which campaigns are burning budget without converting, and what the 7-day GMV trend looks like across brands.

---

## Screenshots

| Dashboard | SKUs | Campaigns |
|---|---|---|
| GMV trend + alert cards | Sortable list + ROAS badges | Spend efficiency bars |

---

## Features

- **Dashboard** — 7-day GMV trend chart, ROAS alert banner, stat cards (GMV / Orders / ROAS / Spend), brand GMV breakdown bars
- **SKU List** — searchable, sortable by ROAS / GMV / Orders / Spend, ROAS health badges (green/orange/red), lazy loading
- **SKU Detail** — full metrics, 7-day sparkline chart, performance gauge bars
- **Campaigns** — spend efficiency bars showing ad spend vs GMV ratio, CTR metrics, ROAS alert coloring
- **Brand filter** — filters all 3 tabs simultaneously via global state

---

## Architecture

```
AppState (ObservableObject)     ← single source of truth, like a Redux store
    │
    ├── SKUService              ← fetches + caches SKU data only (SRP)
    ├── CampaignService         ← fetches + caches campaign data only (SRP)
    └── StatsService            ← aggregates metrics only, no fetching (SRP)
            │
            └── LRUCache<K,V>   ← O(1) get/set, thread-safe, generic
```

### Engineering concepts implemented

**1. Global State Management (like Redux)**
`AppState` is an `ObservableObject` with `@Published` properties. Every view subscribes via `@ObservedObject`. Changing the brand filter on one tab instantly updates all three tabs — unidirectional data flow with no manual refresh.

```swift
// AppState.swift — single source of truth
@Published var selectedBrand: Brand? = nil
@Published var skuSortOrder: SKUSortOrder = .roasDesc

var filteredSKUs: [SKU] {
    // computed from published state — views always up to date
}
```

**2. LRU Cache (same concept as Redis/Memcache)**
All service fetches go through a generic `LRUCache<Key, Value>` backed by a doubly-linked list + hash map. Cache hits are O(1) and skip the data layer entirely.

```swift
// LRUCache.swift — O(1) get and set
func get(_ key: Key) -> Value?   // cache hit → return immediately
func set(_ key: Key, value: Value) // cache miss → fetch, store, return
```

**3. SOLID Principles**
- **Single Responsibility** — `SKUService` only handles SKUs. `CampaignService` only handles campaigns. `StatsService` only aggregates. Nothing does two jobs.
- **Open/Closed** — ROAS threshold logic lives in one place (`SKU.roasAlert`). Change the threshold once, every view updates automatically.
- **Dependency Inversion** — `AppState` receives services via constructor injection. Swap mock data for a real API by changing one line inside the service.

**4. Lazy Loading**
`LazyVStack` in `SKUListView` and `CampaignListView` means rows only allocate memory when scrolled into view. 100 SKUs in the list — only the visible 8 exist in memory.

```swift
ScrollView {
    LazyVStack(spacing: 10) {   // rows render on scroll, not upfront
        ForEach(state.filteredSKUs) { sku in
            SKURowView(sku: sku).equatable()
        }
    }
}
```

**5. Memoization**
`SKURowView` and `CampaignRowView` conform to `Equatable`. SwiftUI's diffing engine skips re-rendering a row if its underlying data hasn't changed — same concept as `React.memo()`.

```swift
struct SKURowView: View, Equatable {
    static func == (lhs: SKURowView, rhs: SKURowView) -> Bool {
        lhs.sku == rhs.sku  // only redraws if ROAS, GMV, orders, or status changed
    }
}
```

**6. Reactive Pipeline (like RxJS)**
`AppState` uses Combine's `Publishers.CombineLatest` to recompute stats automatically whenever brand filter or date range changes — no manual trigger needed.

```swift
Publishers.CombineLatest($selectedBrand, $dateRange)
    .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
    .sink { [weak self] _, _ in
        self?.stats = self?.statsService.computeStats(...)
    }
```

---

## Mock Data

All data is real — pulled from actual internship campaign results:

| Brand | SKUs | GMV (7d) | ROAS | Campaigns |
|---|---|---|---|---|
| Hegen Indonesia | 3 | IDR 83.4M | 10.3× (top SKU) | 2 |
| Oball Indonesia | 4 | IDR 72.4M | 4.4×–5.1× | 3 |
| Baabaasheepz × Snoopy | 3 | IDR 444.6M | 5.6× (launch peak) | 3 |

The Baabaasheepz × Snoopy numbers reflect the Aug 26 2025 licensed IP grand launch — $50K+ revenue within hours of launch, IDR 560M net sales across Aug–Sep 2025.

---

## Why I built this

As an intern managing 5 TikTok Shop accounts simultaneously, my daily workflow was:

1. Open FastMoss → check competitor video performance
2. Open TikTok Ads Manager × 5 accounts → check ROAS per SKU
3. Open Google Sheets → update the tracking dashboard manually

That's 3 tools and ~30 minutes every morning. This app consolidates the operator's view into one place — ROAS alerts surface immediately, brand filtering works across all tabs, and the GMV trend shows whether yesterday's campaign adjustments are working.

---

## Tech Stack

- **Swift 5.9** + **SwiftUI** (iOS 16+)
- **Swift Charts** — native charting framework for GMV trend
- **Combine** — reactive state pipeline
- No third-party dependencies

---

## Running the App

```bash
git clone https://github.com/matthewisoe/tiktokshop-dashboard.git
cd tiktokshop-dashboard
open ShopDashboard.xcodeproj
```

Select an iPhone simulator or device → ⌘ + R to run.

> Requires Xcode 15+ and iOS 16.0+
