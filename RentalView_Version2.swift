import SwiftUI

struct RentalView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedFormat: String = ""
    @State private var selectedLens: Lens? = nil

    var selectedRentalName: String {
        dataManager.appData?.rentals.first(where: { $0.id == dataManager.selectedRentalId })?.name ?? "Rentals"
    }

    var body: some View {
        ZStack {
            createBackgroundGradient()
            
            VStack(spacing: 20) {
                createHeaderSection()
                createFilterSection()
                createContentSection()
            }
            .sheet(item: $selectedLens) { lens in
                LensDetailView(lens: lens)
                    .environmentObject(dataManager)
            }
        }
        .preferredColorScheme(.dark)
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
        HStack {
            Text(selectedRentalName)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.15), radius: 10, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.25), value: selectedRentalName)
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 22)
    }
    
    private func createFilterSection() -> some View {
        HStack(spacing: 16) {
            createRentalFilterMenu()
            createFormatFilterMenu()
        }
        .padding(.horizontal, 24)
    }
    
    private func createRentalFilterMenu() -> some View {
        Menu {
            Picker("Rental", selection: $dataManager.selectedRentalId) {
                Text("Choose rental").tag("")
                ForEach(dataManager.appData?.rentals ?? []) { rental in
                    Text(rental.name).tag(rental.id)
                }
            }
        } label: {
            GlassFilterChip(
                icon: "building.2",
                title: dataManager.selectedRentalId.isEmpty ? "Choose rental" : (dataManager.appData?.rentals.first { $0.id == dataManager.selectedRentalId }?.name ?? "Rental"),
                accentColor: dataManager.selectedRentalId.isEmpty ? .blue : .green,
                isActive: !dataManager.selectedRentalId.isEmpty
            )
        }
    }
    
    private func createFormatFilterMenu() -> some View {
        Menu {
            Picker("Format", selection: $selectedFormat) {
                Text("All Formats").tag("")
                ForEach(Array(Set(dataManager.availableLenses.map { $0.format })).sorted(), id: \.self) { format in
                    Text(format).tag(format)
                }
            }
        } label: {
            GlassFilterChip(
                icon: "crop",
                title: selectedFormat.isEmpty ? "All Formats" : selectedFormat,
                accentColor: selectedFormat.isEmpty ? .blue : .green,
                isActive: !selectedFormat.isEmpty
            )
        }
    }
    
    private func createContentSection() -> some View {
        Group {
            if dataManager.loadingState == .loading {
                createLoadingView()
            } else if let _ = dataManager.appData, !dataManager.selectedRentalId.isEmpty {
                createLensListView()
            } else {
                createEmptyStateView()
            }
        }
    }
    
    private func createLoadingView() -> some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            Text("Loading...")
                .foregroundColor(.white.opacity(0.6))
                .font(.subheadline)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createLensListView() -> some View {
        WeatherStyleLensListView(
            rentalId: dataManager.selectedRentalId,
            format: selectedFormat
        ) { lens in
            selectedLens = lens
        }
    }
    
    private func createEmptyStateView() -> some View {
        VStack {
            Image(systemName: "building.2")
                .font(.system(size: 54))
                .foregroundColor(.blue.opacity(0.4))
                .padding(.bottom, 8)
            Text("Choose rental to see lenses")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}