//
//  ContentView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// ContentView.swift
// Root view — owns AppState (single instance for entire app).
// Passes state down to each tab via @ObservedObject.
// This is the top of the unidirectional data flow:
//   AppState → ContentView → DashboardView / SKUListView / CampaignListView
//
// Interview talking point:
//   "AppState is instantiated once here at the root and passed down
//    as an @ObservedObject. No child view owns or creates data —
//    they only read from and write to the shared state. This is
//    unidirectional data flow, equivalent to Redux in React."

import SwiftUI

struct ContentView: View {

    // Single source of truth — created once, lives for app lifetime
    @StateObject private var state = AppState()

    var body: some View {
        TabView {

            // Dashboard tab
            DashboardView(state: state)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            // SKUs tab — with alert badge
            SKUListView(state: state)
                .tabItem {
                    Label("SKUs", systemImage: "square.grid.2x2.fill")
                }
                .badge(state.alertSKUs.count > 0 ? state.alertSKUs.count : 0)

            // Campaigns tab
            CampaignListView(state: state)
                .tabItem {
                    Label("Campaigns", systemImage: "megaphone.fill")
                }
        }
        .tint(.blue)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}