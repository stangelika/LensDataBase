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
            VStack(spacing: 36) {
                ForEach(filteredGroups) { group in
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(group.manufacturer)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .blue.opacity(0.92)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.16), radius: 4, x: 0, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, 28)

                        ForEach(group.series) { series in
                            WeatherStyleLensSeriesView(series: series, onSelect: onSelect)
                        }
                    }
                    .padding(.bottom, 2)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 30/255, green: 32/255, blue: 54/255, opacity: 1),
                    Color(.sRGB, red: 22/255, green: 22/255, blue: 32/255, opacity: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
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
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(15)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.indigo.opacity(isExpanded ? 0.32 : 0.18), lineWidth: isExpanded ? 2 : 1.2)
                    }
                )
                .shadow(color: .blue.opacity(isExpanded ? 0.10 : 0.04), radius: isExpanded ? 6 : 2, x: 0, y: 2)
                .padding(.horizontal, 22)
            }
            .buttonStyle(NoHighlightButtonStyle())

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(series.lenses) { lens in
                        WeatherStyleLensRow(lens: lens)
                            .onTapGesture {
                                onSelect(lens)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 7)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }
}

struct WeatherStyleLensRow: View {
    let lens: Lens

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                // Новый формат: lens_name + focal_length
                Text("\(lens.lens_name) \(lens.focal_length)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Оставляем только бейдж формата (если Full Frame)
                if lens.format.contains("FF") {
                    HStack(spacing: 11) {
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
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.blue.opacity(0.15), lineWidth: 1)
            }
        )
        .shadow(color: Color.blue.opacity(0.06), radius: 2, x: 0, y: 2)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

struct WeatherStyleLensBadge: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .imageScale(.small)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
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