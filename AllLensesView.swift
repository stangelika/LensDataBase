import SwiftUI

struct AllLensesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedFormat: String = ""
    @State private var selectedFocalCategory: FocalCategory = .all
    @State private var selectedLens: Lens? = nil
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            createBackgroundGradient()
            
            VStack(spacing: 20) {
                createHeaderSection()
                createSearchSection()
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
                Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func createHeaderSection() -> some View {
        HStack {
            Text("Lenses")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .purple.opacity(0.85), .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .purple.opacity(0.18), radius: 12, x: 0, y: 6)
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 22)
    }
    
    private func createSearchSection() -> some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search lenses by name...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: .blue.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 24)
    }
    
    private func createFilterSection() -> some View {
        HStack(spacing: 16) {
            createFormatFilterMenu()
            createFocalLengthFilterMenu()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 2)
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
                accentColor: selectedFormat.isEmpty ? .purple : .green,
                isActive: !selectedFormat.isEmpty
            )
        }
    }
    
    private func createFocalLengthFilterMenu() -> some View {
        Menu {
            Picker("Focal Length Category", selection: $selectedFocalCategory) {
                ForEach(FocalCategory.allCases, id: \.self) { cat in
                    Text(cat.displayName).tag(cat)
                }
            }
        } label: {
            GlassFilterChip(
                icon: "arrow.left.and.right",
                title: selectedFocalCategory.displayName,
                accentColor: selectedFocalCategory == .all ? .indigo : .orange,
                isActive: selectedFocalCategory != .all
            )
        }
    }
    
    private func createContentSection() -> some View {
        Group {
            if dataManager.loadingState == .loading {
                createLoadingView()
            } else if dataManager.availableLenses.isEmpty {
                createEmptyStateView()
            } else {
                createLensListView()
            }
        }
    }
    
    private func createLoadingView() -> some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.5)
            Text("Loading...")
                .foregroundColor(.white.opacity(0.6))
                .font(.subheadline)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createEmptyStateView() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 54))
                .foregroundColor(.purple.opacity(0.4))
            Text("No lenses available")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createLensListView() -> some View {
        WeatherStyleLensListView(
            format: selectedFormat,
            focalCategory: selectedFocalCategory,
            searchText: searchText
        ) { lens in
            selectedLens = lens
        }
    }
}

// MARK: - Supporting Types

/// Focal length categories for filtering lenses
enum FocalCategory: String, CaseIterable, Identifiable {
    case all
    case ultraWide
    case wide
    case standard
    case tele
    case superTele

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .ultraWide: return "Ultra Wide (≤12mm)"
        case .wide: return "Wide (13–35mm)"
        case .standard: return "Standard (36–70mm)"
        case .tele: return "Tele (71–180mm)"
        case .superTele: return "Super Tele (181mm+)"
        }
    }

    /// Checks if a focal length value falls within this category
    /// - Parameter focal: The focal length value to check
    /// - Returns: True if the focal length is within this category
    func contains(focal: Double?) -> Bool {
        guard let focal = focal else { return false }
        switch self {
        case .all: return true
        case .ultraWide: return focal <= 12
        case .wide: return focal >= 13 && focal <= 35
        case .standard: return focal >= 36 && focal <= 70
        case .tele: return focal >= 71 && focal <= 180
        case .superTele: return focal > 180
        }
    }
}

// MARK: - Extensions

extension Lens {
    /// Extracts the main focal value from the focal_length string
    var mainFocalValue: Double? {
        let numbers = focal_length
            .components(separatedBy: CharacterSet(charactersIn: "-– "))
            .compactMap { Double($0.filter("0123456789.".contains)) }
        return numbers.first
    }
}

// MARK: - Filter Chip Component

/// Modern glass-style filter chip for UI controls
struct GlassFilterChip: View {
    let icon: String
    let title: String
    let accentColor: Color
    var isActive: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 17, weight: .semibold))
            
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer(minLength: 2)
            
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .blur(radius: 0.6)
                
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isActive ? accentColor.opacity(0.7) : accentColor.opacity(0.28),
                        lineWidth: isActive ? 2.3 : 1.3
                    )
            }
        )
        .shadow(
            color: accentColor.opacity(isActive ? 0.20 : 0.07),
            radius: isActive ? 9 : 3,
            x: 0,
            y: 3
        )
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .animation(.easeInOut(duration: 0.19), value: isActive)
    }
}