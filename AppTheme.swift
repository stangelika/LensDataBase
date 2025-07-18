import SwiftUI

// MARK: - App Theme

/// Centralized theme system for the LensDataBase app
enum AppTheme {

    // MARK: - Colors

    enum Colors {
        // Primary colors
        static let primary = Color(.sRGB, red: 0.4, green: 0.6, blue: 1.0, opacity: 1.0)
        static let primaryLight = Color(.sRGB, red: 0.5, green: 0.7, blue: 1.0, opacity: 1.0)
        static let primaryDark = Color(.sRGB, red: 0.3, green: 0.5, blue: 0.9, opacity: 1.0)

        // Background colors
        static let backgroundPrimary = Color(.sRGB, red: 24 / 255, green: 27 / 255, blue: 37 / 255, opacity: 1)
        static let backgroundSecondary = Color(.sRGB, red: 34 / 255, green: 37 / 255, blue: 57 / 255, opacity: 1)
        static let backgroundTertiary = Color(.sRGB, white: 0.09, opacity: 1)

        // Surface colors
        static let surfacePrimary = Color.white.opacity(0.1)
        static let surfaceSecondary = Color.white.opacity(0.05)
        static let surfaceHighlight = Color.white.opacity(0.2)

        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.secondary
        static let textTertiary = Color.white.opacity(0.7)

        // Accent colors
        static let accent = Color.green
        static let accentSecondary = Color.purple
        static let warning = Color.orange
        static let error = Color.red

        // Glass morphism colors
        static let glassPrimary = Color.white.opacity(0.1)
        static let glassSecondary = Color.white.opacity(0.05)
        static let glassBorder = Color.white.opacity(0.2)
    }

    // MARK: - Typography

    enum Typography {
        // Display fonts
        static let displayLarge = Font.system(size: 36, weight: .heavy, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let displaySmall = Font.system(size: 24, weight: .semibold, design: .rounded)

        // Headline fonts
        static let headlineLarge = Font.system(size: 22, weight: .bold, design: .default)
        static let headlineMedium = Font.system(size: 18, weight: .semibold, design: .default)
        static let headlineSmall = Font.system(size: 16, weight: .medium, design: .default)

        // Body fonts
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

        // Label fonts
        static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)

        // Caption fonts
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let round: CGFloat = 50
    }

    // MARK: - Shadows

    enum Shadows {
        static let small = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let large = Color.black.opacity(0.3)

        // Glass morphism shadows
        static let glass = Color.purple.opacity(0.18)
        static let glassHighlight = Color.white.opacity(0.3)
    }

    // MARK: - Gradients

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Colors.backgroundPrimary, Colors.backgroundSecondary],
            startPoint: .top,
            endPoint: .bottom)

        static let secondary = LinearGradient(
            colors: [Colors.backgroundTertiary, Color(.sRGB, white: 0.15, opacity: 1)],
            startPoint: .top,
            endPoint: .bottom)

        static let accent = LinearGradient(
            colors: [.white, .purple.opacity(0.85), .blue],
            startPoint: .leading,
            endPoint: .trailing)

        static let glass = LinearGradient(
            colors: [Colors.glassPrimary, Colors.glassSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    // MARK: - Animations

    enum Animations {
        static let fast = Animation.easeInOut(duration: 0.2)
        static let medium = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)

        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let springFast = Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - View Modifiers

extension View {

    /// Applies glass morphism effect to the view
    func glassEffect() -> some View {
        self
            .background(AppTheme.Gradients.glass)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
    }

    /// Applies glass morphism effect with custom corner radius
    func glassEffect(cornerRadius: CGFloat) -> some View {
        self
            .background(AppTheme.Gradients.glass)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    /// Applies primary text style
    func primaryTextStyle() -> some View {
        self
            .font(AppTheme.Typography.bodyLarge)
            .foregroundColor(AppTheme.Colors.textPrimary)
    }

    /// Applies secondary text style
    func secondaryTextStyle() -> some View {
        self
            .font(AppTheme.Typography.bodyMedium)
            .foregroundColor(AppTheme.Colors.textSecondary)
    }

    /// Applies headline text style
    func headlineTextStyle() -> some View {
        self
            .font(AppTheme.Typography.headlineLarge)
            .foregroundColor(AppTheme.Colors.textPrimary)
    }

    /// Applies display text style with gradient
    func displayTextStyle() -> some View {
        self
            .font(AppTheme.Typography.displayLarge)
            .foregroundStyle(AppTheme.Gradients.accent)
            .shadow(color: AppTheme.Shadows.glass, radius: 12, x: 0, y: 6)
    }

    /// Applies standard button style
    func buttonStyle() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.surfacePrimary)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
    }

    /// Applies card style
    func cardStyle() -> some View {
        self
            .padding(AppTheme.Spacing.lg)
            .glassEffect()
            .shadow(color: AppTheme.Shadows.medium, radius: 8, x: 0, y: 4)
    }
}
