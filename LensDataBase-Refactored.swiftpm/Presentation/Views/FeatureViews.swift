import SwiftUI

// MARK: - Filter Sheet View

struct FilterSheetView: View {
    let viewModel: LensListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground(gradient: AppTheme.Colors.primaryGradient)
                
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Format filter
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Format")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Picker("Format", selection: Binding(
                            get: { viewModel.selectedFormat },
                            set: { viewModel.selectedFormat = $0 }
                        )) {
                            Text("All Formats").tag("")
                            ForEach(viewModel.availableFormats, id: \.self) { format in
                                Text(format).tag(format)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .appCard()
                    }
                    
                    // Focal length category filter
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Focal Length")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Picker("Focal Length", selection: Binding(
                            get: { viewModel.selectedFocalCategory },
                            set: { viewModel.selectedFocalCategory = $0 }
                        )) {
                            ForEach(FocalLengthCategory.allCases) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .appCard()
                    }
                    
                    // Manufacturer filter
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Manufacturer")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Picker("Manufacturer", selection: Binding(
                            get: { viewModel.selectedManufacturer },
                            set: { viewModel.selectedManufacturer = $0 }
                        )) {
                            Text("All Manufacturers").tag("")
                            ForEach(viewModel.availableManufacturers, id: \.self) { manufacturer in
                                Text(manufacturer).tag(manufacturer)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .appCard()
                    }
                    
                    Spacer()
                    
                    // Apply and reset buttons
                    HStack(spacing: AppTheme.Spacing.md) {
                        Button("Reset Filters") {
                            viewModel.selectedFormat = ""
                            viewModel.selectedFocalCategory = .all
                            viewModel.selectedManufacturer = ""
                            viewModel.showOnlyRentable = false
                            Task { await viewModel.applyFilters() }
                        }
                        .appButton(style: .secondary)
                        
                        Button("Apply") {
                            Task { await viewModel.applyFilters() }
                            dismiss()
                        }
                        .appButton(style: .primary)
                    }
                    .padding(.bottom, AppTheme.Spacing.lg)
                }
                .padding(AppTheme.Spacing.lg)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @State private var viewModel = DependencyContainer.shared.makeFavoritesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground(gradient: AppTheme.Colors.primaryGradient)
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading favorites...")
                } else if viewModel.favorites.isEmpty {
                    EmptyStateView(
                        title: "No Favorites Yet",
                        subtitle: "Add lenses to your favorites by tapping the heart icon",
                        systemImage: "heart.circle"
                    )
                } else {
                    List {
                        ForEach(viewModel.favorites) { lens in
                            FavoriteLensRowView(lens: lens, viewModel: viewModel)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(
                isPresented: $viewModel.showingError,
                message: viewModel.errorMessage
            )
            .task {
                await viewModel.loadFavorites()
            }
        }
    }
}

// MARK: - Favorite Lens Row View

struct FavoriteLensRowView: View {
    let lens: Lens
    let viewModel: FavoritesViewModel
    
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
                    Button(action: { Task { await viewModel.removeFavorite(lens) } }) {
                        Image(systemName: "heart.slash")
                            .foregroundColor(AppTheme.Colors.error)
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
            isInComparison = await viewModel.isInComparison(lens)
            canAddToComparison = await viewModel.canAddToComparison()
        }
    }
}

// MARK: - Comparison View

struct ComparisonView: View {
    @State private var viewModel = DependencyContainer.shared.makeComparisonViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground(gradient: AppTheme.Colors.primaryGradient)
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading comparison...")
                } else if viewModel.comparisonLenses.isEmpty {
                    EmptyStateView(
                        title: "No Lenses to Compare",
                        subtitle: "Add lenses to comparison by tapping the plus icon",
                        systemImage: "rectangle.split.3x1"
                    )
                } else {
                    VStack(spacing: AppTheme.Spacing.md) {
                        // Header with clear button
                        HStack {
                            Text("Comparing \(viewModel.comparisonLenses.count) lens(es)")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Button("Clear All") {
                                Task { await viewModel.clearComparison() }
                            }
                            .appButton(style: .destructive)
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Comparison grid
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(viewModel.comparisonLenses.count, 2)), spacing: AppTheme.Spacing.md) {
                                ForEach(viewModel.comparisonLenses) { lens in
                                    ComparisonLensCardView(lens: lens, viewModel: viewModel)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                    }
                }
            }
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(
                isPresented: $viewModel.showingError,
                message: viewModel.errorMessage
            )
            .task {
                await viewModel.loadComparison()
            }
        }
    }
}

// MARK: - Comparison Lens Card View

struct ComparisonLensCardView: View {
    let lens: Lens
    let viewModel: ComparisonViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header with remove button
            HStack {
                Text(lens.displayName)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: { Task { await viewModel.removeFromComparison(lens) } }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.error)
                }
            }
            
            // Specifications
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                SpecificationRow(label: "Manufacturer", value: lens.manufacturer)
                SpecificationRow(label: "Format", value: lens.format)
                SpecificationRow(label: "Focal Length", value: lens.focalLength)
                SpecificationRow(label: "Aperture", value: "f/\(lens.aperture)")
                SpecificationRow(label: "Close Focus", value: "\(lens.specifications.closeFocusDistance.inches)\" / \(lens.specifications.closeFocusDistance.centimeters)cm")
            }
            
            Spacer()
            
            // Detail button
            NavigationLink(destination: LensDetailView(lensId: lens.id)) {
                Text("View Details")
                    .frame(maxWidth: .infinity)
                    .appButton(style: .primary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .appCard()
    }
}

// MARK: - Specification Row

struct SpecificationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Rental View

struct RentalView: View {
    @State private var viewModel = DependencyContainer.shared.makeRentalViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground(gradient: AppTheme.Colors.primaryGradient)
                
                if viewModel.isLoading {
                    LoadingView(message: "Loading rentals...")
                } else if viewModel.rentals.isEmpty {
                    EmptyStateView(
                        title: "No Rental Data",
                        subtitle: "Rental information is currently unavailable",
                        systemImage: "building.2.circle"
                    )
                } else {
                    VStack(spacing: 0) {
                        // Rental selector
                        if viewModel.rentals.count > 1 {
                            Picker("Rental", selection: Binding(
                                get: { viewModel.selectedRental },
                                set: { if let rental = $0 { Task { await viewModel.selectRental(rental) } } }
                            )) {
                                ForEach(viewModel.rentals) { rental in
                                    Text(rental.displayName).tag(rental as Rental?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(AppTheme.Spacing.lg)
                            .appCard()
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                        
                        // Selected rental info
                        if let selectedRental = viewModel.selectedRental {
                            RentalInfoView(rental: selectedRental)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                        
                        // Lenses list
                        if !viewModel.lensesForSelectedRental.isEmpty {
                            List {
                                ForEach(viewModel.lensesForSelectedRental) { lens in
                                    NavigationLink(destination: LensDetailView(lensId: lens.id)) {
                                        SimpleLensRowView(lens: lens)
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
            .navigationTitle("Rentals")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(
                isPresented: $viewModel.showingError,
                message: viewModel.errorMessage
            )
            .task {
                await viewModel.loadRentals()
            }
        }
    }
}

// MARK: - Rental Info View

struct RentalInfoView: View {
    let rental: Rental
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(rental.displayName)
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if let location = rental.location {
                Text(location.address)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            HStack {
                if !rental.contactInformation.phone.isEmpty {
                    Link(destination: URL(string: "tel:\(rental.contactInformation.phone)")!) {
                        Label(rental.contactInformation.phone, systemImage: "phone.fill")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                
                Spacer()
                
                if !rental.contactInformation.website.isEmpty {
                    Link(destination: URL(string: rental.contactInformation.website)!) {
                        Label("Website", systemImage: "safari.fill")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .appCard()
    }
}

// MARK: - Simple Lens Row View

struct SimpleLensRowView: View {
    let lens: Lens
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.md)
        .appCard()
    }
}