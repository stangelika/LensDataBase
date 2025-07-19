import SwiftUI

struct RentalView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var selectedFormat: String = ""

    @State private var selectedLens: Lens? = nil

    var selectedRentalName: String {
        dataManager.appData? .rentals.first(where: {
            $0.id    == dataManager.selectedRentalId
        }
        )? .name ?? "Rentals"
    }
    var body: some View {
        ZStack {
            AppTheme.Colors.detailViewGradient
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xxl) {
                HStack {
                    Text(selectedRentalName)
                    .font(.appLargeTitle)
                    .foregroundStyle(
                    LinearGradient(
                    colors: [AppTheme.Colors.primaryText, AppTheme.Colors.blue, AppTheme.Colors.indigo], startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    )
                    .shadow(color: AppTheme.Colors.blue.opacity(0.15), radius: 10, x: 0, y: 4)
                    .animation(.easeInOut(duration: 0.25), value: selectedRentalName)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                HStack(spacing: 16) {
                    Menu {
                        Picker("Rental", selection: $dataManager.selectedRentalId) {
                            Text("Choose rental").tag("")

                            ForEach(dataManager.appData? .rentals ?? []) {
                                rental in
                                Text(rental.name).tag(rental.id)
                            }

                        }

                    }
                    label: {
                        GlassFilterChip(
                        icon: "building.2", title: dataManager.selectedRentalId.isEmpty ? "Choose rental" : (dataManager.appData?.rentals.first {
                            $0.id == dataManager.selectedRentalId
                        }?.name ?? "Rental"), accentColor: dataManager.selectedRentalId.isEmpty ? AppTheme.Colors.blue : AppTheme.Colors.green, isActive: !dataManager.selectedRentalId.isEmpty
                        )
                    }
                    Menu {
                        Picker("Format", selection: $selectedFormat) {
                            Text("All Formats").tag("")

                            ForEach(Array(Set(dataManager.availableLenses.map(\.format))).sorted(), id: \.self) {
                                format in
                                Text(format).tag(format)
                            }

                        }

                    }
                    label: {
                        GlassFilterChip(
                        icon: "crop", title: selectedFormat.isEmpty ? "All Formats": selectedFormat, accentColor: selectedFormat.isEmpty ? AppTheme.Colors.blue: AppTheme.Colors.green, isActive: !selectedFormat.isEmpty
                        )
                    }

                }
                .padding(.horizontal, AppTheme.Spacing.padding24)

                if dataManager.loadingState    == .loading {
                    VStack {
                        ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.blue))
                        .scaleEffect(1.5)
                        Text("Loading...")
                        .foregroundColor(AppTheme.Colors.quaternaryText)
                        .font(.appBody)
                        .padding(.top, AppTheme.Spacing.sm)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if let _ = dataManager.appData, !dataManager.selectedRentalId.isEmpty {
                    WeatherStyleLensListView(
                    lensesSource: dataManager.groupLenses(forRental: dataManager.selectedRentalId).compactMap {
                        group in

                        let filteredSeries = group.series.compactMap {
                            series in
                            let filteredLenses = series.lenses.filter {
                                selectedFormat.isEmpty || $0.format    == selectedFormat
                            }
                            return filteredLenses.isEmpty ? nil: LensSeries(name: series.name, lenses: filteredLenses)
                        }
                        return filteredSeries.isEmpty ? nil: LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
                    }, onSelect: {
                        lens in

                        selectedLens = lens
                    }
                    )
                }
                else {
                    VStack {
                        Image(systemName: "building.2")
                        .font(.system(size: 54))
                        .foregroundColor(AppTheme.Colors.blue.opacity(0.4))
                        .padding(.bottom, AppTheme.Spacing.md)
                        Text("Choose rental to see lenses")
                        .font(.appHeadline)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
