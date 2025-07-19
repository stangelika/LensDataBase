
import SwiftUI

struct ComparisonView: View {
    @EnvironmentObject var dataManager: DataManager

    @Environment(\.presentationMode) var presentationMode

    private var lensesToCompare: [Lens] {
        dataManager.comparisonSet.compactMap {
            lensId in
            dataManager.availableLenses.first {
                $0.id    == lensId
            }

        }
        .sorted {
            $0.display_name < $1.display_name
        }

    }
    private let specs: [(String, KeyPath<Lens, String>)] = [
    ("Format", \.format), ("Focal Length", \.focal_length), ("Aperture", \.aperture), ("Image Circle", \.image_circle), ("Close Focus", \.close_focus_cm), ("Front Diameter", \.front_diameter), ("Length", \.length), ]

    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Comparison")
                    .font(.appTitle.weight(.bold))
                    .gradientText(AppTheme.Colors.favoriteTitleGradient)

                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }
                    ) {
                        Text("Done")
                        .font(.appHeadline.weight(.bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small, style: .continuous)
                        .fill(.ultraThinMaterial)
                        )
                    }

                }
                .padding()
                .foregroundColor(AppTheme.Colors.primaryText)

                ScrollView {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Feature")
                            .font(.appHeadline.weight(.bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(AppTheme.Spacing.lg)
                            .frame(height: 120, alignment: .leading)

                            ForEach(specs, id: \.0) {
                                spec in
                                Text(spec.0)
                                .font(.appBodyMedium)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(AppTheme.Spacing.lg)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 60)
                            }

                        }
                        .frame(width: 140)
                        .glassCard(cornerRadius: AppTheme.CornerRadius.medium)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: AppTheme.Spacing.lg) {
                                ForEach(lensesToCompare) {
                                    lens in

                                    VStack(alignment: .leading, spacing: 0) {
                                        ComparisonCell(
                                        text: "\(lens.display_name)\n\(lens.manufacturer)", isHeader: true
                                        )

                                        ForEach(specs, id: \.0) {
                                            spec in
                                            ComparisonCell(text: lens[keyPath: spec.1])
                                        }

                                    }
                                    .glassCard(cornerRadius: AppTheme.CornerRadius.medium)
                                }

                            }
                            .padding(.leading, AppTheme.Spacing.lg)
                        }

                    }
                    .padding()
                }

            }

        }
        .preferredColorScheme(.dark)
    }

}
struct ComparisonCell: View {
    let text: String
    var isHeader: Bool = false

    var body: some View {
        Text(text)
        .font(isHeader ? .appHeadline.weight(.bold): .appMonospace)
        .foregroundColor(AppTheme.Colors.primaryText)
        .padding(AppTheme.Spacing.lg)
        .frame(width: 150, height: isHeader ? 120: 60, alignment: .leading)
        .background(isHeader ? AppTheme.Colors.toolbarBackground: Color.clear)
        .lineLimit(isHeader ? 3: 2)
    }

}
