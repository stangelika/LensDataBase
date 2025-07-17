import SwiftUI

struct LensDetailView: View, Identifiable {
    let id = UUID()
    let lens: Lens
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showCompatibilityCheck = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                createHeaderSection()
                createTitleSection()
                createSpecificationsGrid()
                createRentalsSection()
            }
            .padding(.bottom, 30)
        }
        .background(createBackgroundGradient())
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCompatibilityCheck) {
            CameraLensVisualizerRoot(lens: lens)
        }
    }
    
    // MARK: - UI Components
    
    private func createBackgroundGradient() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 27/255, green: 29/255, blue: 48/255, opacity: 1),
                Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func createHeaderSection() -> some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Lens title
            StickyHeader(title: lens.display_name)
        }
    }
    
    private func createTitleSection() -> some View {
        HStack(alignment: .top) {
            // Lens information
            VStack(alignment: .leading, spacing: 10) {
                Text("\(lens.manufacturer) · \(lens.lens_name)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Favorite button
            Button(action: {
                dataManager.toggleFavorite(lens: lens)
            }) {
                Image(systemName: dataManager.isFavorite(lens: lens) ? "star.fill" : "star")
                    .font(.title2.weight(.bold))
                    .foregroundColor(dataManager.isFavorite(lens: lens) ? .yellow : .gray)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .yellow.opacity(dataManager.isFavorite(lens: lens) ? 0.3 : 0), radius: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dataManager.isFavorite(lens: lens))
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal)
    }
    
    private func createSpecificationsGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible())], spacing: 18) {
            // Specification cards
            createSpecificationCards()
            
            // Action buttons
            createActionButtons()
        }
        .padding(.horizontal)
    }
    
    private func createSpecificationCards() -> some View {
        Group {
            SpecCard(
                title: "Focal Length",
                value: lens.focal_length,
                icon: "arrow.left.and.right",
                color: .blue
            )
            
            SpecCard(
                title: "Aperture",
                value: lens.aperture,
                icon: "camera.aperture",
                color: .purple
            )
            
            SpecCard(
                title: "Format",
                value: lens.format,
                icon: "crop",
                color: .green
            )
            
            SpecCard(
                title: "Min Distance",
                value: lens.close_focus_cm.isEmpty ? lens.close_focus_in : lens.close_focus_cm,
                icon: "ruler",
                color: .orange
            )
            
            SpecCard(
                title: "Image Circle",
                value: lens.image_circle,
                icon: "circle.dashed",
                color: .teal
            )
            
            if let squeeze = lens.squeeze_factor, squeeze != "N/A" {
                SpecCard(
                    title: "Squeeze Factor",
                    value: squeeze,
                    icon: "aspectratio",
                    color: .pink
                )
            }
            
            SpecCard(
                title: "Length",
                value: lens.length,
                icon: "arrow.up.and.down",
                color: .indigo
            )
            
            SpecCard(
                title: "Front Diameter",
                value: lens.front_diameter,
                icon: "circle",
                color: .brown
            )
        }
    }
    
    private func createActionButtons() -> some View {
        Group {
            Button(action: {
                searchLensInGoogle()
            }) {
                SpecCard(
                    title: "Action",
                    value: "Google Search",
                    icon: "photo.on.rectangle.angled",
                    color: .blue
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                showCompatibilityCheck = true
            }) {
                SpecCard(
                    title: "Action",
                    value: "Check Compatibility",
                    icon: "camera.metering.center.weighted",
                    color: .green
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func createRentalsSection() -> some View {
        let rentals = dataManager.rentalsForLens(lens.id)
        return Group {
            if !rentals.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Available for Rent")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                    
                    ForEach(rentals) { rental in
                        Button(action: {
                            navigateToRental(rental)
                        }) {
                            RentalCard(rental: rental)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Actions
    
    private func searchLensInGoogle() {
        let query = lens.display_name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? lens.display_name
        if let url = URL(string: "https://www.google.com/search?tbm=isch&q=\(query)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func navigateToRental(_ rental: Rental) {
        dataManager.selectedRentalId = rental.id
        dataManager.activeTab = .rentalView
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views

/// Sticky header for the lens detail view
struct StickyHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 33, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.10), radius: 6, x: 0, y: 2)
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal)
    }
}

/// Specification card component
struct SpecCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(color.opacity(0.15))
                    )
                
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.leading, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

/// Rental card component
struct RentalCard: View {
    let rental: Rental
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text(rental.name)
                    .font(.headline.weight(.semibold))
                Spacer()
                Image(systemName: "building.2")
                    .foregroundColor(.secondary)
            }
            
            Text(rental.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 4)
            
            HStack(spacing: 16) {
                ContactButton(
                    label: rental.phone,
                    icon: "phone",
                    color: .green,
                    action: {
                        callPhoneNumber(rental.phone)
                    }
                )
                
                ContactButton(
                    label: "Website",
                    icon: "globe",
                    color: .blue,
                    action: {
                        openWebsite(rental.website)
                    }
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func callPhoneNumber(_ phone: String) {
        if let url = URL(string: "tel://\(phone.filter("0123456789+".contains))") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openWebsite(_ website: String) {
        if let url = URL(string: website) {
            UIApplication.shared.open(url)
        }
    }
}

/// Contact button for rental cards
struct ContactButton: View {
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .imageScale(.small)
                
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .foregroundColor(color)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.16))
            )
        }
    }
}