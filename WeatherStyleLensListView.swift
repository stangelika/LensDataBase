import SwiftUI

struct WeatherStyleLensListView: View {
    @EnvironmentObject var dataManager: DataManager
    let rentalId: String?
    let format: String
    let focalCategory: FocalCategory
    let onSelect: (Lens) -> Void

    init(rentalId: String? = nil, format: String = "", focalCategory: FocalCategory = .all, onSelect: @escaping (Lens) -> Void) {
        self.rentalId = rentalId
        self.format = format
        self.focalCategory = focalCategory
        self.onSelect = onSelect
    }

    private var filteredGroups: [LensGroup] {
        let groups = dataManager.groupLenses(forRental: rentalId)
        guard !format.isEmpty || focalCategory != .all else { return groups }
        return groups.compactMap { group in
            let filteredSeries = group.series.compactMap { series in
                let filteredLenses = series.lenses.filter {
                    (format.isEmpty || $0.format == format)
                    && focalCategory.contains(focal: $0.mainFocalValue)
                }
                return filteredLenses.isEmpty ? nil : LensSeries(name: series.name, lenses: filteredLenses)
            }
            return filteredSeries.isEmpty ? nil : LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                ForEach(filteredGroups) { group in
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                        HStack {
                            Text(group.manufacturer)
                                .font(DesignSystem.Typography.title)
                                .foregroundStyle(DesignSystem.Gradients.textPrimary)
                                .designSystemShadow(DesignSystem.Shadows.md)
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.headerSpacing)

                        ForEach(group.series) { series in
                            WeatherStyleLensSeriesView(series: series, onSelect: onSelect)
                        }
                    }
                }
            }
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
        .background(
            DesignSystem.Gradients.secondaryBackground
                .ignoresSafeArea()
        )
    }
}

struct WeatherStyleLensSeriesView: View {
    let series: LensSeries
    let onSelect: (Lens) -> Void
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(series.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(DesignSystem.Spacing.lg)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(Color.indigo.opacity(isExpanded ? 0.32 : 0.18), lineWidth: isExpanded ? 2 : 1.2)
                    }
                )
                .shadow(color: .blue.opacity(isExpanded ? 0.10 : 0.04), radius: isExpanded ? 6 : 2, x: 0, y: 2)
                .padding(.horizontal, DesignSystem.Spacing.contentInsets)
            }
            .buttonStyle(NoHighlightButtonStyle())

            if isExpanded {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(series.lenses) { lens in
                        WeatherStyleLensRow(lens: lens)
                            .onTapGesture {
                                onSelect(lens)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xxxl)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }
}

struct WeatherStyleLensRow: View {
    let lens: Lens

    var body: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                // Новый формат: lens_name + focal_length
                Text("\(lens.lens_name) \(lens.focal_length)")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Оставляем только бейдж формата (если Full Frame)
                if lens.format.contains("FF") {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        WeatherStyleLensBadge(
                            icon: "crop",
                            value: lens.format,
                            color: .green
                        )
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 18, weight: .medium))
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(Color.blue.opacity(0.15), lineWidth: 1)
            }
        )
        .designSystemShadow(DesignSystem.Shadows.sm)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

struct WeatherStyleLensBadge: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .imageScale(.small)
                .foregroundColor(color)
            Text(value)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(.white)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(color.opacity(0.19))
        )
    }
}

struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.82 : 1.0)
    }
}