import SwiftUI

enum AppThemeValidation {
    static func validateTheme() -> Bool {
        var isValid = true

        let testGradients = [
        AppTheme.Colors.primaryGradient, AppTheme.Colors.mainTabGradient, AppTheme.Colors.listViewGradient, AppTheme.Colors.detailViewGradient, AppTheme.Colors.titleGradient, AppTheme.Colors.favoriteTitleGradient, AppTheme.Colors.manufacturerGradient, AppTheme.Colors.stickyHeaderGradient, ]

        let testSpacings: [CGFloat] = [
        AppTheme.Spacing.xs, AppTheme.Spacing.sm, AppTheme.Spacing.md, AppTheme.Spacing.lg, AppTheme.Spacing.xl, AppTheme.Spacing.xxl, AppTheme.Spacing.xxxl, ]

        let testRadii: [CGFloat] = [
        AppTheme.CornerRadius.small, AppTheme.CornerRadius.medium, AppTheme.CornerRadius.large, AppTheme.CornerRadius.xlarge, ]

        for spacing in testSpacings {
            if spacing   <= 0 {
                print("❌ Invalid spacing value: \(spacing)")
                isValid = false
            }

        }
        for radius in testRadii {
            if radius   <= 0 {
                print("❌ Invalid corner radius value: \(radius)")
                isValid = false
            }

        }
        let testFonts: [Font] = [
        .appLargeTitle, .appTitle, .appTitle2, .appHeadline, .appBody, .appBodyMedium, .appCaption, .appMonospace, .appRounded18, .appRounded14, ]

        print("✅ Theme validation completed with \(testGradients.count) gradients, \(testSpacings.count) spacings, \(testRadii.count) radii, and \(testFonts.count) fonts")

        return isValid
    }
    static func printThemeUsageReport() {
        print("📊 AppTheme Usage Report: ")
        print(" - Colors: \(Mirror(reflecting: AppTheme.Colors.self).children.count) properties")
        print(" - Spacing: \(Mirror(reflecting: AppTheme.Spacing.self).children.count) properties")
        print(" - Corner Radius: \(Mirror(reflecting: AppTheme.CornerRadius.self).children.count) properties")
        print(" - Font Extensions: 10 custom fonts defined")
        print(" - View Modifiers: 4 reusable modifiers")
    }

}
struct ThemeShowcaseView: View {
    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient
            .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xxl) {
                Text("Theme Showcase")
                .font(.appLargeTitle)
                .gradientText(AppTheme.Colors.titleGradient)

                HStack(spacing: AppTheme.Spacing.xl) {
                    VStack {
                        Text("Sample Card")
                        .font(.appHeadline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                        Text("Using AppTheme")
                        .font(.appBody)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .padding(AppTheme.Spacing.xl)
                    .glassCard()

                    VStack {
                        Text("Another Card")
                        .font(.appHeadline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                        Text("Consistent Style")
                        .font(.appBody)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .padding(AppTheme.Spacing.xl)
                    .glassCard()
                }
                Text("Filter Chip Example")
                .font(.appBodyMedium)
                .foregroundColor(AppTheme.Colors.primaryText)
                .padding(.vertical, AppTheme.Spacing.padding11)
                .padding(.horizontal, AppTheme.Spacing.padding18)
                .filterChip(accentColor: AppTheme.Colors.blue, isActive: true)
            }
            .padding(AppTheme.Spacing.xxxl)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            let _ = AppThemeValidation.validateTheme()
            AppThemeValidation.printThemeUsageReport()
        }

    }

}
