import SwiftUI

struct RentalAndSettingsView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var selectedFormat: String = ""
    @State private var selectedLens: Lens? = nil

    var selectedRentalName: String {
        guard
            let appData = dataManager.appData,
            !dataManager.selectedRentalId.isEmpty,
            let rentalName = appData.rentals.first(where: { $0.id == dataManager.selectedRentalId })?.name
        else {
            return "Rentals"
        }
        return rentalName
    }

    // Оптимизированная фильтрация
    var filteredGroups: [LensGroup] {
        print("🟡 Строим filteredGroups для рентала \(dataManager.selectedRentalId) и формата '\(selectedFormat)'")
        let result = dataManager.groupLenses(forRental: dataManager.selectedRentalId)
            .map { group in
                let filteredSeries = group.series.map { series in
                    let filteredLenses = selectedFormat.isEmpty
                        ? series.lenses
                        : series.lenses.filter {
                            dataManager.normalizeFormat($0.format) == dataManager.normalizeFormat(selectedFormat)
                        }
                    return LensSeries(name: series.name, lenses: filteredLenses)
                }
                .filter { !$0.lenses.isEmpty }
                print("🟢 Группа \(group.manufacturer): \(filteredSeries.count) серий")
                for s in filteredSeries {
                    print("  Серия \(s.name): \(s.lenses.count) линз после фильтра")
                }
                return LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
            }
            .filter { !$0.series.isEmpty }
        print("🔵 Всего групп после фильтрации: \(result.count)")
        return result
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.detailViewGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxl) {

                    // Заголовок
                    HStack {
                        Text(selectedRentalName)
                            .font(.appLargeTitle)
                            .gradientText(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.primaryText,
                                        AppTheme.Colors.blue,
                                        AppTheme.Colors.indigo
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppTheme.Colors.blue.opacity(0.15), radius: 10, x: 0, y: 4)
                            .animation(.easeInOut(duration: 0.25), value: selectedRentalName)
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.xxxl)
                    .padding(.top, AppTheme.Spacing.padding22)

                    // Фильтры
                    HStack(spacing: 16) {
                        Menu {
                            Picker("Rental", selection: $dataManager.selectedRentalId) {
                                Text("Choose rental").tag("")
                                ForEach(dataManager.appData?.rentals ?? []) {
                                    Text($0.name).tag($0.id)
                                }
                            }
                        } label: {
                            GlassFilterChip(
                                icon: "building.2",
                                title: dataManager.selectedRentalId.isEmpty ? "Choose rental" : selectedRentalName,
                                accentColor: dataManager.selectedRentalId.isEmpty ? AppTheme.Colors.blue : AppTheme.Colors.green,
                                isActive: !dataManager.selectedRentalId.isEmpty
                            )
                        }

                        Menu {
                            // Только уникальные и непустые форматы
                            let uniqueFormats = Set(dataManager.availableLenses.map {
                                dataManager.normalizeFormat($0.format)
                            }).filter { !$0.isEmpty }

                            Picker("Format", selection: $selectedFormat) {
                                Text("All Formats").tag("")
                                ForEach(uniqueFormats.sorted(), id: \.self) { format in
                                    Text(format).tag(format)
                                }
                            }
                        } label: {
                            GlassFilterChip(
                                icon: "crop",
                                title: selectedFormat.isEmpty ? "All Formats" : selectedFormat,
                                accentColor: selectedFormat.isEmpty ? AppTheme.Colors.blue : AppTheme.Colors.green,
                                isActive: !selectedFormat.isEmpty
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.padding24)

                    // Контент
                    if dataManager.loadingState == .loading {
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
                    } else if filteredGroups.isEmpty {
                        VStack(spacing: 18) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            Text("Нет линз для выбранных фильтров")
                                .font(.appBody)
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                                .padding()
                            Button("Сбросить фильтры") {
                                selectedFormat = ""
                                // можно добавить сброс других фильтров, например dataManager.selectedRentalId = ""
                            }
                            .font(.appBody.bold())
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        WeatherStyleLensListView(
                            lensesSource: filteredGroups,
                            onSelect: { selectedLens = $0 }
                        )
                    }

                    Spacer(minLength: 30)

                    Text("⚠️ Please verify rental information on official websites before making bookings.")
                        .font(.footnote)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, AppTheme.Spacing.lg)
                }
                .sheet(item: $selectedLens) {
                    LensDetailView(lens: $0)
                        .environmentObject(dataManager)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}