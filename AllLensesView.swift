import SwiftUI

struct AllLensesView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var selectedLens: Lens? = nil

    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xxl) {
                HStack {
                    Text("Lenses")
                    .font(.appLargeTitle)
                    .gradientText(AppTheme.Colors.titleGradient)
                    .shadow(color: AppTheme.Colors.purple.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                HStack(spacing: AppTheme.Spacing.xl) {
                    Menu {
                        Picker("Format", selection: $dataManager.allLensesSelectedFormat) {
                            Text("All Formats").tag("")

                            ForEach(Array(Set(dataManager.availableLenses.map(\.format))).sorted(), id: \.self) {
                                format in
                                Text(format).tag(format)
                            }

                        }

                    }
                    label: {
                        GlassFilterChip(
                        icon: "crop", title: dataManager.allLensesSelectedFormat.isEmpty ? "All Formats": dataManager.allLensesSelectedFormat, accentColor: dataManager.allLensesSelectedFormat.isEmpty ? AppTheme.Colors.purple: AppTheme.Colors.green, isActive: !dataManager.allLensesSelectedFormat.isEmpty
                        )
                    }
                    Menu {
                        Picker("Focal Length Category", selection: $dataManager.allLensesSelectedFocalCategory) {
                            ForEach(FocalCategory.allCases, id: \.self) {
                                cat in
                                Text(cat.displayName).tag(cat)
                            }

                        }

                    }
                    label: {
                        GlassFilterChip(
                        icon: "arrow.left.and.right", title: dataManager.allLensesSelectedFocalCategory.displayName, accentColor: dataManager.allLensesSelectedFocalCategory    == .all ? AppTheme.Colors.indigo: AppTheme.Colors.orange, isActive: dataManager.allLensesSelectedFocalCategory    != .all
                        )
                    }
                    Button(action: {
                        withAnimation {
                            dataManager.allLensesShowOnlyRentable.toggle()
                        }

                    }
                    ) {
                        GlassFilterChip(
                        icon: "building.2", title: "In Rental", accentColor: AppTheme.Colors.blue, isActive: dataManager.allLensesShowOnlyRentable
                        )
                    }

                }
                .padding(.horizontal, AppTheme.Spacing.padding24)
                .padding(.bottom, AppTheme.Spacing.xs)

                if dataManager.loadingState    == .loading {
                    VStack {
                        ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.purple))
                        .scaleEffect(1.5)
                        Text("Loading...")
                        .foregroundColor(AppTheme.Colors.quaternaryText)
                        .font(.appBody)
                        .padding(.top, AppTheme.Spacing.sm)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if dataManager.availableLenses.isEmpty {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "camera.metering.unknown")
                        .font(.system(size: 54))
                        .foregroundColor(AppTheme.Colors.purple.opacity(0.4))
                        Text("No lenses available")
                        .font(.appHeadline)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    WeatherStyleLensListView(
                    lensesSource: dataManager.groupedAndFilteredLenses
                    ) {
                        lens in

                        selectedLens = lens
                    }

                }

            }
            .sheet(item: $selectedLens) {
                lens in

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

    var id: String {
        rawValue
    }
    var displayName: String {
        switch self {
            case .all: "All"
            case .ultraWide: "Ultra Wide (≤12mm)"
            case .wide: "Wide (13–35mm)"
            case .standard: "Standard (36–70mm)"
            case .tele: "Tele (71–180mm)"
            case .superTele: "Super Tele (181mm + )"
        }

    }
    func contains(focal: Double? ) -> Bool {
        guard let focal else {
            return false
        }
        switch self {
            case .all: return true
            case .ultraWide: return focal   <= 12
            case .wide: return focal   >= 13 && focal   <= 35
            case .standard: return focal   >= 36 && focal   <= 70
            case .tele: return focal   >= 71 && focal   <= 180
            case .superTele: return focal > 180
        }

    }

}
extension Lens {
    var mainFocalValue: Double? {
        let numbers = focal_length
        .components(separatedBy: CharacterSet(charactersIn: " - – "))
        .compactMap {
            Double($0.filter("0123456789.".contains))
        }
        return numbers.first
    }

}
struct GlassFilterChip: View {
    let icon: String

    let title: String

    let accentColor: Color

    var isActive: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
            .foregroundColor(accentColor)
            .font(.system(size: 17, weight: .semibold))

            Text(title)
            .font(.appBodyMedium)
            .foregroundColor(AppTheme.Colors.primaryText)
            .lineLimit(1)
            Spacer(minLength: AppTheme.Spacing.xs)

            Image(systemName: "chevron.down")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .padding(.vertical, AppTheme.Spacing.padding11)
        .padding(.horizontal, AppTheme.Spacing.padding18)
        .filterChip(accentColor: accentColor, isActive: isActive, cornerRadius: AppTheme.CornerRadius.large)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }

}
