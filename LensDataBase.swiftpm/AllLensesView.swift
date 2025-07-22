import SwiftUI

struct AllLensesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLens: Lens? = nil
    @State private var searchText: String = ""
    @State private var selectedLensFormatCategory: LensFormatCategory? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State private var groupByManufacturerAndName: Bool = true

    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient.ignoresSafeArea()
            VStack(spacing: AppTheme.Spacing.xxl) {
                // Header and filters
                HStack {
                    Text("Lenses")
                        .font(.appLargeTitle)
                        .gradientText(AppTheme.Colors.titleGradient)
                        .shadow(color: AppTheme.Colors.purple.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                    // Кнопка Rent Only
                    Button {
                        withAnimation { dataManager.allLensesShowOnlyRentable.toggle() }
                    } label: {
                        RentalFilterButton(isActive: dataManager.allLensesShowOnlyRentable)
                    }
                    // Toggle grouping button
                    Button {
                        withAnimation { groupByManufacturerAndName.toggle() }
                    } label: {
                        Image(systemName: groupByManufacturerAndName ? "rectangle.3.offgrid" : "rectangle.grid.1x2")
                            .foregroundColor(groupByManufacturerAndName ? AppTheme.Colors.purple : AppTheme.Colors.green)
                            .font(.system(size: 22, weight: .semibold))
                            .padding(8)
                            .background(AppTheme.Colors.cardBackground)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.Colors.purple.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .help(groupByManufacturerAndName ? "Disable grouping" : "Enable grouping")
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                HStack(spacing: AppTheme.Spacing.xl) {
                    // Фильтр формата объектива
                    Menu {
                        Picker("Format", selection: $dataManager.allLensesSelectedFormat) {
                            Text("All Formats").tag("")
                            ForEach(Array(Set(dataManager.availableLenses.map(\.format))).sorted(), id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                    } label: {
                        GlassFilterChip(
                            icon: "crop",
                            title: dataManager.allLensesSelectedFormat.isEmpty ? "All Formats" : dataManager.allLensesSelectedFormat,
                            accentColor: dataManager.allLensesSelectedFormat.isEmpty ? AppTheme.Colors.purple : AppTheme.Colors.green,
                            isActive: !dataManager.allLensesSelectedFormat.isEmpty
                        )
                    }

                    // Фокусное расстояние
                    Menu {
                        Picker("Focal Length Category", selection: $dataManager.allLensesSelectedFocalCategory) {
                            ForEach(FocalCategory.allCases) {
                                Text($0.displayName).tag($0)
                            }
                        }
                    } label: {
                        GlassFilterChip(
                            icon: "arrow.left.and.right",
                            title: dataManager.allLensesSelectedFocalCategory.displayName,
                            accentColor: dataManager.allLensesSelectedFocalCategory == .all ? AppTheme.Colors.indigo : AppTheme.Colors.orange,
                            isActive: dataManager.allLensesSelectedFocalCategory != .all
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.padding24)
                .padding(.bottom, AppTheme.Spacing.xs)

                // Контент
                if dataManager.loadingState == .loading {
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
                } else if dataManager.availableLenses.isEmpty {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.system(size: 54))
                            .foregroundColor(AppTheme.Colors.purple.opacity(0.4))
                        Text("No lenses available")
                            .font(.appHeadline)
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // --- Фильтрация ---
                    let filteredLenses = dataManager.groupedAndFilteredLenses.map { group in
                        let filteredSeries = group.series.compactMap { series in
                            let lenses = series.lenses.filter {
                                (searchText.isEmpty || $0.display_name.lowercased().contains(searchText.lowercased())) &&
                                (selectedLensFormatCategory == nil || selectedLensFormatCategory!.contains(lensFormat: $0.lens_format))
                            }
                            return lenses.isEmpty ? nil : LensSeries(name: series.name, lenses: lenses)
                        }
                        return filteredSeries.isEmpty ? nil : LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
                    }.compactMap { $0 }

                    if groupByManufacturerAndName {
                        // Grouped list
                        WeatherStyleLensListView(lensesSource: filteredLenses) { lens in
                            selectedLens = lens
                        }
                    } else {
                        // Flat list without grouping
                        FlatLensListView(lenses: filteredLenses.flatMap { $0.series.flatMap { $0.lenses } }) { lens in
                            selectedLens = lens
                        }
                    }
                }
            }

            // Поисковая строка + lens_format category фильтр поверх списка
            VStack(spacing: 12) {
                Spacer()
                GlassSearchBar(text: $searchText)
                    .padding(.horizontal, AppTheme.Spacing.padding24)
                Menu {
                    Picker("Lens Format Category", selection: $selectedLensFormatCategory) {
                        Text("All Lens Formats").tag(LensFormatCategory?.none)
                        ForEach(LensFormatCategory.allCases) { category in
                            Text(category.displayName).tag(Optional(category))
                        }
                    }
                } label: {
                    GlassFilterChip(
                        icon: "circle.lefthalf.fill",
                        title: selectedLensFormatCategory == nil ? "All Lens Formats" : selectedLensFormatCategory!.displayName,
                        accentColor: selectedLensFormatCategory == nil ? AppTheme.Colors.indigo : AppTheme.Colors.green,
                        isActive: selectedLensFormatCategory != nil
                    )
                }
                .padding(.horizontal, AppTheme.Spacing.padding24)
                .padding(.bottom, keyboardHeight == 0 ? 80 : keyboardHeight + 10)
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(item: $selectedLens) { lens in
            LensDetailView(lens: lens)
                .environmentObject(dataManager)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notif in
                if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeOut(duration: 0.25)) {
                        keyboardHeight = frame.height
                    }
                }
            }
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = 0
                }
            }
        }
    }
}
// MARK: - Filter & Models

// MARK: - UI Components

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

struct RentalFilterButton: View {
    var isActive: Bool

    let activeGradient = LinearGradient(
        colors: [AppTheme.Colors.blue, AppTheme.Colors.purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "building.2")
                .font(.system(size: 17, weight: .semibold))
            Text("Rent Only")
                .font(.appBodyMedium)
                .lineLimit(1)
        }
        .padding(.vertical, AppTheme.Spacing.padding11)
        .padding(.horizontal, AppTheme.Spacing.padding18)
        .background {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .fill(isActive ? AnyShapeStyle(activeGradient) : AnyShapeStyle(AppTheme.Colors.cardBackground))
        }
        .foregroundColor(isActive ? .white : AppTheme.Colors.tertiaryText)
        .shadow(color: AppTheme.Colors.blue.opacity(isActive ? 0.4 : 0), radius: 8, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

struct GlassSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.secondaryText)

            ZStack(alignment: .leading) {
                if text.isEmpty && !isFocused {
                    Text("Search lenses...")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .padding(.leading, 2)
                }

                TextField("", text: $text)
                    .focused($isFocused)
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .disableAutocorrection(true)
            }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.indigo,
                            AppTheme.Colors.blue,
                            AppTheme.Colors.purple
                        ],
                        startPoint: .bottomTrailing,
                        endPoint: .topLeading
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .stroke(AppTheme.Colors.titleGradient, lineWidth: 1.5)
                )
                .shadow(color: AppTheme.Colors.purple.opacity(0.2), radius: 10, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
}


