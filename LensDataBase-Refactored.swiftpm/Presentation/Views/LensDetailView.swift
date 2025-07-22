import SwiftUI

// MARK: - Lens Detail View

struct LensDetailView: View {
    let lensId: String
    @State private var viewModel: LensDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(lensId: String) {
        self.lensId = lensId
        self._viewModel = State(initialValue: DependencyContainer.shared.makeLensDetailViewModel(lensId: lensId))
    }
    
    var body: some View {
        ZStack {
            GradientBackground(gradient: AppTheme.Colors.detailGradient)
            
            if viewModel.isLoading {
                LoadingView(message: "Loading lens details...")
            } else if let lens = viewModel.lens {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Header
                        LensDetailHeaderView(lens: lens, viewModel: viewModel)
                        
                        // Specifications
                        LensSpecificationsView(lens: lens)
                        
                        // Physical Properties
                        PhysicalPropertiesView(lens: lens)
                        
                        // Compatible Cameras
                        if !viewModel.compatibleCameras.isEmpty {
                            CompatibleCamerasView(cameras: viewModel.compatibleCameras)
                        }
                        
                        // Available Rentals
                        if !viewModel.availableRentals.isEmpty {
                            AvailableRentalsView(rentals: viewModel.availableRentals)
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            } else {
                EmptyStateView(
                    title: "Lens Not Found",
                    subtitle: "The requested lens could not be loaded",
                    systemImage: "camera.circle.fill"
                )
            }
        }
        .navigationTitle(viewModel.lens?.displayName ?? "Lens Details")
        .navigationBarTitleDisplayMode(.large)
        .errorAlert(
            isPresented: $viewModel.showingError,
            message: viewModel.errorMessage
        )
        .task {
            await viewModel.loadLensDetails()
        }
    }
}

// MARK: - Lens Detail Header View

struct LensDetailHeaderView: View {
    let lens: Lens
    let viewModel: LensDetailViewModel
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Title
            Text(lens.displayName)
                .font(AppTheme.Typography.largeTitle)
                .gradientText(AppTheme.Colors.titleGradient)
                .multilineTextAlignment(.center)
            
            // Manufacturer and Format
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(lens.manufacturer)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.accent)
                
                Text(lens.format)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Quick specs
            HStack(spacing: AppTheme.Spacing.xxl) {
                QuickSpecView(
                    title: "Focal Length",
                    value: lens.focalLength,
                    icon: "camera.viewfinder"
                )
                
                QuickSpecView(
                    title: "Aperture",
                    value: "f/\(lens.aperture)",
                    icon: "camera.aperture"
                )
            }
            
            // Action buttons
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: { Task { await viewModel.toggleFavorite() } }) {
                    Label(
                        viewModel.isFavorite ? "Remove Favorite" : "Add Favorite",
                        systemImage: viewModel.isFavorite ? "heart.slash" : "heart.fill"
                    )
                }
                .appButton(style: viewModel.isFavorite ? .warning : .accent)
                
                Button(action: { Task { await viewModel.toggleComparison() } }) {
                    Label(
                        viewModel.isInComparison ? "Remove from Compare" : "Add to Compare",
                        systemImage: viewModel.isInComparison ? "minus.circle" : "plus.circle"
                    )
                }
                .appButton(style: viewModel.isInComparison ? .warning : .primary)
                .disabled(!viewModel.canAddToComparison && !viewModel.isInComparison)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .appCard()
    }
}

// MARK: - Quick Spec View

struct QuickSpecView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppTheme.Colors.accent)
            
            Text(value)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

// MARK: - Lens Specifications View

struct LensSpecificationsView: View {
    let lens: Lens
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeaderView(title: "Specifications", icon: "list.bullet.rectangle")
            
            VStack(spacing: AppTheme.Spacing.sm) {
                DetailSpecificationRow(
                    label: "Format",
                    value: lens.specifications.format
                )
                
                DetailSpecificationRow(
                    label: "Focal Length",
                    value: lens.specifications.focalLength
                )
                
                DetailSpecificationRow(
                    label: "Maximum Aperture",
                    value: "f/\(lens.specifications.aperture)"
                )
                
                DetailSpecificationRow(
                    label: "Close Focus (Imperial)",
                    value: lens.specifications.closeFocusDistance.inches.isEmpty ? "N/A" : "\(lens.specifications.closeFocusDistance.inches)\""
                )
                
                DetailSpecificationRow(
                    label: "Close Focus (Metric)",
                    value: lens.specifications.closeFocusDistance.centimeters.isEmpty ? "N/A" : "\(lens.specifications.closeFocusDistance.centimeters) cm"
                )
                
                if let imageCircle = lens.specifications.imageCircle, !imageCircle.isEmpty {
                    DetailSpecificationRow(
                        label: "Image Circle",
                        value: imageCircle
                    )
                }
                
                if let squeezeFactor = lens.specifications.squeezeFactor, !squeezeFactor.isEmpty {
                    DetailSpecificationRow(
                        label: "Squeeze Factor",
                        value: squeezeFactor
                    )
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .appCard()
    }
}

// MARK: - Physical Properties View

struct PhysicalPropertiesView: View {
    let lens: Lens
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeaderView(title: "Physical Properties", icon: "ruler")
            
            VStack(spacing: AppTheme.Spacing.sm) {
                DetailSpecificationRow(
                    label: "Length",
                    value: lens.physicalProperties.length.isEmpty ? "N/A" : lens.physicalProperties.length
                )
                
                DetailSpecificationRow(
                    label: "Front Diameter",
                    value: lens.physicalProperties.frontDiameter.isEmpty ? "N/A" : lens.physicalProperties.frontDiameter
                )
                
                if let weight = lens.physicalProperties.weight, !weight.isEmpty {
                    DetailSpecificationRow(
                        label: "Weight",
                        value: weight
                    )
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .appCard()
    }
}

// MARK: - Compatible Cameras View

struct CompatibleCamerasView: View {
    let cameras: [Camera]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeaderView(title: "Compatible Cameras", icon: "camera.fill")
            
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(cameras.prefix(5)) { camera in
                    CameraRowView(camera: camera)
                }
                
                if cameras.count > 5 {
                    Text("And \(cameras.count - 5) more...")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.top, AppTheme.Spacing.sm)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .appCard()
    }
}

// MARK: - Camera Row View

struct CameraRowView: View {
    let camera: Camera
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "camera.fill")
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(camera.displayName)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Sensor: \(camera.sensor.type)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}

// MARK: - Available Rentals View

struct AvailableRentalsView: View {
    let rentals: [Rental]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeaderView(title: "Available at Rentals", icon: "building.2.fill")
            
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(rentals) { rental in
                    RentalRowView(rental: rental)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .appCard()
    }
}

// MARK: - Rental Row View

struct RentalRowView: View {
    let rental: Rental
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(rental.displayName)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if let location = rental.location, !location.address.isEmpty {
                Text(location.address)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            HStack(spacing: AppTheme.Spacing.lg) {
                if !rental.contactInformation.phone.isEmpty {
                    Link(destination: URL(string: "tel:\(rental.contactInformation.phone)")!) {
                        Label(rental.contactInformation.phone, systemImage: "phone.fill")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
                
                if !rental.contactInformation.website.isEmpty {
                    Link(destination: URL(string: rental.contactInformation.website)!) {
                        Label("Website", systemImage: "safari.fill")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

// MARK: - Section Header View

struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.accent)
                .font(.system(size: 18, weight: .medium))
            
            Text(title)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Detail Specification Row

struct DetailSpecificationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
}