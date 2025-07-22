import SwiftUI

struct AllLensesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedFormat: String = ""
    @State private var selectedFocalCategory: FocalCategory = .all
    @State private var selectedLens: Lens? = nil

    var body: some View {
        ZStack {
            // Background using design system
            DesignSystem.Gradients.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header with consistent spacing
                HStack {
                    Text("Lenses")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundStyle(DesignSystem.Gradients.textSecondary)
                        .shadow(color: .purple.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.headerSpacing)
                .padding(.top, DesignSystem.Spacing.xxl)

                // Filter chips with consistent spacing
                HStack(spacing: DesignSystem.Spacing.lg) {
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
                .padding(.horizontal, DesignSystem.Spacing.contentInsets)

                // Content with consistent spacing
                if dataManager.loadingState == .loading {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if dataManager.availableLenses.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.system(size: 54))
                            .foregroundColor(.purple.opacity(0.4))
                        Text("No lenses available")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    WeatherStyleLensListView(
                        format: selectedFormat,
                        focalCategory: selectedFocalCategory
                    ) { lens in
                        selectedLens = lens
                    }
                }
            }
            .sheet(item: $selectedLens) { lens in
                LensDetailView(lens: lens)
                    .environmentObject(dataManager)
            }
        }
        .preferredColorScheme(.dark)
    }
}

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

extension Lens {
    var mainFocalValue: Double? {
        let numbers = focal_length
            .components(separatedBy: CharacterSet(charactersIn: "-– "))
            .compactMap { Double($0.filter("0123456789.".contains)) }
        return numbers.first
    }
}

// Updated filter chip with design system spacing
struct GlassFilterChip: View {
    let icon: String
    let title: String
    let accentColor: Color
    var isActive: Bool = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 17, weight: .semibold))
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 2)
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .blur(radius: 0.6)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(isActive ? accentColor.opacity(0.7) : accentColor.opacity(0.28), lineWidth: isActive ? 2.3 : 1.3)
            }
        )
        .shadow(color: accentColor.opacity(isActive ? 0.20 : 0.07), radius: isActive ? 9 : 3, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
        .animation(.easeInOut(duration: 0.19), value: isActive)
    }
}