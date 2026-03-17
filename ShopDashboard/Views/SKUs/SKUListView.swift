//
//  SKUListView.swift
//  ShopDashboard
//
//  Created by Matt Irv on 3/17/26.
//


// SKUListView.swift
// Single Responsibility: renders the SKU list screen only.
// LazyVStack = lazy loading — rows only render when scrolled into view.
// Search + sort controls feed into AppState, which recomputes filteredSKUs.

import SwiftUI

struct SKUListView: View {

    @ObservedObject var state: AppState

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // Search bar
                searchBar

                // Sort picker
                sortPicker

                // SKU list — LazyVStack for lazy loading
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if state.filteredSKUs.isEmpty {
                            emptyState
                        } else {
                            ForEach(state.filteredSKUs) { sku in
                                NavigationLink(destination: SKUDetailView(sku: sku)) {
                                    SKURowView(sku: sku)
                                        .equatable()  // memoization — skip redraw if SKU unchanged
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("SKUs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Alert badge on toolbar
                    if !state.alertSKUs.isEmpty {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Search bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search SKUs or brand...", text: $state.searchQuery)
                .font(.subheadline)
            if !state.searchQuery.isEmpty {
                Button {
                    state.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Sort picker
    private var sortPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SKUSortOrder.allCases, id: \.self) { order in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            state.skuSortOrder = order
                        }
                    } label: {
                        Text(order.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(state.skuSortOrder == order
                                          ? Color.blue
                                          : Color.gray.opacity(0.12))
                            )
                            .foregroundColor(state.skuSortOrder == order
                                             ? .white : .primary)
                    }
                }

                // SKU count badge
                Text("\(state.filteredSKUs.count) SKUs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Empty state
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No SKUs found")
                .font(.headline)
            Text("Try adjusting your search or filter")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - Preview
#Preview {
    SKUListView(state: AppState())
}