import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            GradientBackground(gradient: AppTheme.Colors.primaryGradient)
            
            TabView(selection: Binding(
                get: { appState.selectedTab },
                set: { appState.selectedTab = $0 }
            )) {
                LensListView()
                    .tabItem {
                        Label(AppTab.lenses.title, systemImage: AppTab.lenses.systemImage)
                    }
                    .tag(AppTab.lenses)
                
                FavoritesView()
                    .tabItem {
                        Label(AppTab.favorites.title, systemImage: AppTab.favorites.systemImage)
                    }
                    .tag(AppTab.favorites)
                
                ComparisonView()
                    .tabItem {
                        Label(AppTab.comparison.title, systemImage: AppTab.comparison.systemImage)
                    }
                    .tag(AppTab.comparison)
                
                RentalView()
                    .tabItem {
                        Label(AppTab.rentals.title, systemImage: AppTab.rentals.systemImage)
                    }
                    .tag(AppTab.rentals)
            }
            .tint(AppTheme.Colors.accent)
        }
        .errorAlert(
            isPresented: Binding(
                get: { appState.showingError },
                set: { _ in appState.clearError() }
            ),
            message: appState.errorMessage
        )
    }
}

// MARK: - Lens List View

struct LensListView: View {
    @State private var viewModel = DependencyContainer.shared.makeLensListViewModel()
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground(gradient: AppTheme.Colors.primaryGradient)
                
                VStack(spacing: 0) {
                    // Header with search and filters
                    HeaderView(
                        searchText: $viewModel.searchText,
                        showingFilterSheet: $showingFilterSheet,
                        groupByManufacturer: $viewModel.groupByManufacturer,
                        showOnlyRentable: $viewModel.showOnlyRentable
                    )
                    
                    // Content
                    if viewModel.isLoading {
                        Spacer()
                        LoadingView(message: "Loading lenses...")
                        Spacer()
                    } else if viewModel.groupedLenses.isEmpty {
                        Spacer()
                        EmptyStateView(
                            title: "No Lenses Found",
                            subtitle: "Try adjusting your search or filter criteria",
                            systemImage: "camera.circle"
                        )
                        Spacer()
                    } else {
                        LensGroupedListView(
                            groups: viewModel.groupedLenses,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .navigationTitle("Lenses")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(viewModel: viewModel)
            }
            .errorAlert(
                isPresented: $viewModel.showingError,
                message: viewModel.errorMessage
            )
            .task {
                await viewModel.loadLenses()
            }
            .onChange(of: viewModel.searchText) { _, _ in
                Task { await viewModel.applyFilters() }
            }
            .onChange(of: viewModel.groupByManufacturer) { _, _ in
                Task { await viewModel.applyFilters() }
            }
            .onChange(of: viewModel.showOnlyRentable) { _, _ in
                Task { await viewModel.applyFilters() }
            }
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var showingFilterSheet: Bool
    @Binding var groupByManufacturer: Bool
    @Binding var showOnlyRentable: Bool
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    TextField("Search lenses...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                
                // Filter button
                Button(action: { showingFilterSheet = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(Circle())
                
                // Group toggle button
                Button(action: { groupByManufacturer.toggle() }) {
                    Image(systemName: groupByManufacturer ? "rectangle.3.offgrid" : "rectangle.grid.1x2")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(groupByManufacturer ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(Circle())
            }
            
            // Quick filter buttons
            HStack {
                FilterChip(
                    title: "Rentable Only",
                    isSelected: showOnlyRentable,
                    action: { showOnlyRentable.toggle() }
                )
                
                Spacer()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
                )
        }
    }
}

// MARK: - Lens Grouped List View

struct LensGroupedListView: View {
    let groups: [LensGroup]
    let viewModel: LensListViewModel
    
    var body: some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.series) { series in
                        if viewModel.groupByManufacturer {
                            DisclosureGroup {
                                ForEach(series.lenses) { lens in
                                    LensRowView(lens: lens, viewModel: viewModel)
                                }
                            } label: {
                                Text(series.name)
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        } else {
                            ForEach(series.lenses) { lens in
                                LensRowView(lens: lens, viewModel: viewModel)
                            }
                        }
                    }
                } header: {
                    if viewModel.groupByManufacturer {
                        Text(group.manufacturer)
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Lens Row View

struct LensRowView: View {
    let lens: Lens
    let viewModel: LensListViewModel
    
    @State private var isFavorite = false
    @State private var isInComparison = false
    @State private var canAddToComparison = true
    
    var body: some View {
        NavigationLink(destination: LensDetailView(lensId: lens.id)) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Lens info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(lens.displayName)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                    
                    Text("\(lens.manufacturer) • \(lens.format)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    HStack {
                        Text(lens.focalLength)
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(AppTheme.Colors.accent)
                        
                        Spacer()
                        
                        Text("f/\(lens.aperture)")
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: AppTheme.Spacing.sm) {
                    Button(action: { Task { await viewModel.toggleFavorite(lens) } }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? AppTheme.Colors.error : AppTheme.Colors.textSecondary)
                    }
                    
                    Button(action: { Task { await viewModel.toggleComparison(lens) } }) {
                        Image(systemName: isInComparison ? "minus.circle.fill" : "plus.circle")
                            .foregroundColor(
                                isInComparison ? AppTheme.Colors.warning : 
                                canAddToComparison ? AppTheme.Colors.accent : AppTheme.Colors.textTertiary
                            )
                    }
                    .disabled(!canAddToComparison && !isInComparison)
                }
            }
            .padding(AppTheme.Spacing.md)
            .appCard()
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            isFavorite = await viewModel.isFavorite(lens)
            isInComparison = await viewModel.isInComparison(lens)
            canAddToComparison = await viewModel.canAddToComparison()
        }
    }
}