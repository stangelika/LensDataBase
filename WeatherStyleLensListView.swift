import SwiftUI

struct WeatherStyleLensListView: View {
    let lensesSource: [LensGroup]

    let onSelect: (Lens) -> Void

    init(lensesSource: [LensGroup], onSelect: @escaping (Lens) -> Void) {
        self.lensesSource = lensesSource
        self.onSelect = onSelect
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.padding36) {
                ForEach(lensesSource) {
                    group in
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                        HStack {
                            Text(group.manufacturer)
                            .font(.appTitle2)
                            .gradientText(AppTheme.Colors.manufacturerGradient)
                            .shadow(color: AppTheme.Colors.blue.opacity(0.16), radius: 4, x: 0, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.xxxl)

                        LazyVStack(spacing: AppTheme.Spacing.xxl) {
                            ForEach(group.series) {
                                series in

                                WeatherStyleLensSeriesView(series: series, onSelect: onSelect)
                            }

                        }

                    }
                    .padding(.bottom, AppTheme.Spacing.xs)
                }

            }
            .padding(.top, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .background(

        AppTheme.Colors.listViewGradient
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

            }
            ) {
                HStack {
                    Text(series.name)
                    .font(.appHeadline)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .lineLimit(1)
                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up": "chevron.down")
                    .foregroundColor(AppTheme.Colors.tertiaryText)
                    .font(.system(size: 16, weight: .medium))
                }
                .padding(AppTheme.Spacing.padding15)
                .background(

                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(
                    AppTheme.Colors.indigo.opacity(isExpanded ? 0.32: 0.18), lineWidth: isExpanded ? 2: 1.2
                    )
                }
                )

                .shadow(
                color: AppTheme.Colors.blue.opacity(isExpanded ? 0.10: 0.04), radius: isExpanded ? 6: 2, x: 0, y: 2
                )
                .padding(.horizontal, AppTheme.Spacing.padding22)
            }
            .buttonStyle(NoHighlightButtonStyle())

            if isExpanded {
                LazyVStack(spacing: AppTheme.Spacing.lg) {
                    ForEach(series.lenses) {
                        lens in

                        WeatherStyleLensRow(lens: lens)
                        .onTapGesture {
                            onSelect(lens)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                }
                .padding(.horizontal, AppTheme.Spacing.padding30)
                .padding(.vertical, 7)
            }

        }
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }

}
struct WeatherStyleLensRow: View {
    let lens: Lens

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.padding18) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.padding6) {
                Text("\(lens.lens_name) \(lens.focal_length)")
                .font(.appRounded18)
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(1)

                if lens.format.contains("FF") {
                    HStack(spacing: AppTheme.Spacing.padding11) {
                        WeatherStyleLensBadge(
                        icon: "crop", value: lens.format, color: AppTheme.Colors.green
                        )
                    }

                }

            }
            Spacer()

            Image(systemName: "chevron.right")
            .foregroundColor(AppTheme.Colors.disabledText)
            .font(.system(size: 18, weight: .medium))
        }
        .padding(.vertical, AppTheme.Spacing.padding14)
        .padding(.horizontal, AppTheme.Spacing.padding18)
        .background(

        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
            .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
            .stroke(AppTheme.Colors.blue.opacity(0.15), lineWidth: 1)
        }
        )

        .shadow(color: AppTheme.Colors.blue.opacity(0.06), radius: 2, x: 0, y: 2)

        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

}
struct WeatherStyleLensBadge: View {
    let icon: String

    let value: String

    let color: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.padding6) {
            Image(systemName: icon)
            .imageScale(.small)
            .foregroundColor(color)

            Text(value)
            .font(.appRounded14)
            .foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.horizontal, AppTheme.Spacing.padding11)
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

        .opacity(configuration.isPressed ? 0.82: 1.0)
    }

}
