# TikTok Shop Seller Dashboard — iOS App

> Built with SwiftUI · Global State Management · LRU Cache · SOLID Architecture

A native iOS seller operations dashboard built from real experience managing **5 TikTok Shop accounts** across Hegen Indonesia, Oball Indonesia, and Baabaasheepz × Snoopy — brands that collectively generated **IDR 702.5M+ GMV** with sustained **ROAS >5×**.

This isn't a tutorial app. It replicates the actual daily workflow an operator runs every morning: which SKUs are underperforming ROAS thresholds, which campaigns are burning budget without converting, and what the 7-day GMV trend looks like across brands.

---

## Screenshots

| Dashboard | SKUs | Campaigns |
|---|---|---|
| ![Dashboard](Screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-03-18%20at%2009.52.32.png) | ![SKUs](Screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-03-18%20at%2009.53.15.png) | ![Campaigns](Screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-03-18%20at%2009.53.46.png) |

| SKU Detail | Brand Filter |
|---|---|
| ![SKU Detail](Screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-03-18%20at%2009.53.15.png) | ![Brand Filter](Screenshots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202026-03-18%20at%2009.53.37.png) |

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

**2. LRU Cache (same concept as Redis/Memcache)**
Generic `LRUCache<Key, Value>` backed by a doubly-linked list + hash map. Cache hits are O(1) and skip the data layer entirely. NSLock for thread safety.

**3. SOLID Principles**
- **Single Responsibility** — `SKUService` only handles SKUs. `CampaignService` only handles campaigns. `StatsService` only aggregates.
- **Open/Closed** — ROAS threshold logic lives in `SKU.roasAlert`. Change the threshold once, every view updates automatically.
- **Dependency Inversion** — `AppState` receives services via constructor injection. Swap mock data for a real API by changing one line.

**4. Lazy Loading**
`LazyVStack` means rows only allocate memory when scrolled into view.

**5. Memoization**
`SKURowView` and `CampaignRowView` conform to `Equatable`. SwiftUI skips re-rendering unchanged rows — same as `React.memo()`.

**6. Reactive Pipeline (Combine)**
`CombineLatest` recomputes stats automatically on filter/date change with 150ms debounce.

---

## Mock Data

Real numbers from actual internship campaigns:

| Brand | GMV (7d) | ROAS | Key Achievement |
|---|---|---|---|
| Hegen Indonesia | IDR 83.4M | 10.3× | 134K-view videos |
| Oball Indonesia | IDR 72.4M | 4.4–5.1× | 419% GMV growth, 327 orders |
| Baabaasheepz × Snoopy | IDR 444.6M | 5.6× | IDR 560M net sales, $50K+ launch-day |

---

## Why I built this

Managing 5 TikTok Shop accounts meant opening FastMoss, TikTok Ads Manager × 5, and Google Sheets every morning — ~30 minutes daily. This app consolidates that into one place: ROAS alerts surface immediately, brand filtering works across all tabs, and the GMV trend shows whether yesterday's campaign adjustments are working.

---

## Tech Stack

- **Swift 5.9** + **SwiftUI** (iOS 16+)
- **Swift Charts** — native GMV trend chart
- **Combine** — reactive state pipeline
- No third-party dependencies

---

## Running
```bash
git clone https://github.com/matthewisoe/tiktokshop-dashboard.git
open tiktokshop-dashboard/ShopDashboard.xcodeproj
```

Select iPhone simulator or device → ⌘ + R
