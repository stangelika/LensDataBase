import SwiftUI

// MARK: - Centralized App Theme System

// This file contains all styling constants and modifiers to ensure visual consistency
// across the entire LensDataBase application

enum AppTheme {
    // MARK: - Colors

    enum Colors {
        // Background Gradients
        static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 24 / 255, green: 27 / 255, blue: 37 / 255, opacity: 1),
                Color(.sRGB, red: 34 / 255, green: 37 / 255, blue: 57 / 255, opacity: 1),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        static let mainTabGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, white: 0.09, opacity: 1),
                Color(.sRGB, white: 0.15, opacity: 1),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        static let listViewGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 30 / 255, green: 32 / 255, blue: 54 / 255, opacity: 1),
                Color(.sRGB, red: 22 / 255, green: 22 / 255, blue: 32 / 255, opacity: 1),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        static let detailViewGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 27 / 255, green: 29 / 255, blue: 48 / 255, opacity: 1),
                Color(.sRGB, red: 38 / 255, green: 36 / 255, blue: 97 / 255, opacity: 1),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        // Text Gradients
        static let titleGradient = LinearGradient(
            colors: [.white, .purple.opacity(0.85), .blue],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let favoriteTitleGradient = LinearGradient(
            colors: [.white, .yellow.opacity(0.85), .orange],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let manufacturerGradient = LinearGradient(
            colors: [.white, .blue.opacity(0.92)],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let stickyHeaderGradient = LinearGradient(
            colors: [.white, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Accent Colors
        static let purple = Color.purple
        static let blue = Color.blue
        static let green = Color.green
        static let orange = Color.orange
        static let yellow = Color.yellow
        static let indigo = Color.indigo
        static let teal = Color.teal
        static let pink = Color.pink
        static let brown = Color.brown

        // Background Colors
        static let cardBackground = Color.white.opacity(0.07)
        static let selectedCardBackground = Color.white.opacity(0.15)
        static let unselectedCardBackground = Color.white.opacity(0.05)
        static let toolbarBackground = Color.white.opacity(0.1)
        static let materialBackground: Color = if #available(iOS 15.0, *) {
            .init(uiColor: .systemBackground).opacity(0.7)
        } else {
            .white.opacity(0.07)
        }

        // Text Colors
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.8)
        static let tertiaryText = Color.white.opacity(0.7)
        static let quaternaryText = Color.white.opacity(0.6)
        static let disabledText = Color.white.opacity(0.5)
        static let captionText = Color.secondary

        // Border Colors
        static let cardBorder = Color.white.opacity(0.1)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let xxxl: CGFloat = 28

        // Common specific spacing values
        static let padding6: CGFloat = 6
        static let padding10: CGFloat = 10
        static let padding11: CGFloat = 11
        static let padding14: CGFloat = 14
        static let padding15: CGFloat = 15
        static let padding18: CGFloat = 18
        static let padding22: CGFloat = 22
        static let padding24: CGFloat = 24
        static let padding30: CGFloat = 30
        static let padding36: CGFloat = 36
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 18
        static let xlarge: CGFloat = 20
    }

    // MARK: - Shadows

    enum Shadows {
        static func titleShadow(color: Color = .purple, opacity: Double = 0.18) -> some View {
            EmptyView().shadow(color: color.opacity(opacity), radius: 12, x: 0, y: 6)
        }

        static func cardShadow(color: Color = .blue, opacity: Double = 0.06) -> some View {
            EmptyView().shadow(color: color.opacity(opacity), radius: 2, x: 0, y: 2)
        }

        static func activeShadow(color: Color = .blue, opacity: Double = 0.10) -> some View {
            EmptyView().shadow(color: color.opacity(opacity), radius: 6, x: 0, y: 2)
        }

        static func filterShadow(color: Color, isActive: Bool) -> some View {
            EmptyView().shadow(
                color: color.opacity(isActive ? 0.20 : 0.07),
                radius: isActive ? 9 : 3,
                x: 0,
                y: 3
            )
        }

        static func glowShadow(color: Color = .yellow, opacity: Double = 0.3) -> some View {
            EmptyView().shadow(color: color.opacity(opacity), radius: 8)
        }

        static func buttonShadow(color: Color = .blue, opacity: Double = 0.5) -> some View {
            EmptyView().shadow(color: color.opacity(opacity), radius: 10, y: 5)
        }
    }

    // MARK: - View Modifiers

    enum Modifiers {
        // Glass Card Modifier
        static func glassCard(
            cornerRadius: CGFloat = CornerRadius.large,
            borderColor: Color = Colors.cardBorder,
            borderWidth: CGFloat = 1
        ) -> some ViewModifier {
            GlassCardModifier(
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                borderWidth: borderWidth
            )
        }

        // Material Background Modifier
        static func materialBackground(
            cornerRadius: CGFloat = CornerRadius.large,
            material: Material = .ultraThinMaterial
        ) -> some ViewModifier {
            MaterialBackgroundModifier(cornerRadius: cornerRadius, material: material)
        }

        // Gradient Text Modifier
        static func gradientText(_ gradient: LinearGradient) -> some ViewModifier {
            GradientTextModifier(gradient: gradient)
        }

        // Filter Chip Modifier
        static func filterChip(
            accentColor: Color,
            isActive: Bool = false,
            cornerRadius: CGFloat = CornerRadius.large
        ) -> some ViewModifier {
            FilterChipModifier(
                accentColor: accentColor,
                isActive: isActive,
                cornerRadius: cornerRadius
            )
        }
    }
}

// MARK: - Font Extensions

extension Font {
    // Title Fonts
    static let appLargeTitle = Font.system(size: 36, weight: .heavy, design: .rounded)
    static let appTitle = Font.system(size: 33, weight: .heavy, design: .rounded)
    static let appTitle2 = Font.system(size: 25, weight: .bold, design: .rounded)

    // Body Fonts
    static let appHeadline = Font.headline.weight(.semibold)
    static let appBody = Font.subheadline
    static let appBodyMedium = Font.subheadline.weight(.medium)
    static let appCaption = Font.caption.weight(.medium)

    // Special Fonts
    static let appMonospace = Font.system(.subheadline, design: .monospaced)
    static let appRounded18 = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let appRounded14 = Font.system(size: 14, weight: .medium, design: .rounded)
}

// MARK: - Custom View Modifiers

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppTheme.Colors.cardBackground)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: borderWidth)
                }
            )
    }
}

struct MaterialBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    let material: Material

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(material)
                        .blur(radius: 0.6)
                }
            )
    }
}

struct GradientTextModifier: ViewModifier {
    let gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .foregroundStyle(gradient)
    }
}

struct FilterChipModifier: ViewModifier {
    let accentColor: Color
    let isActive: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .blur(radius: 0.6)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            isActive ? accentColor.opacity(0.7) : accentColor.opacity(0.28),
                            lineWidth: isActive ? 2.3 : 1.3
                        )
                }
            )
            .shadow(
                color: accentColor.opacity(isActive ? 0.20 : 0.07),
                radius: isActive ? 9 : 3,
                x: 0,
                y: 3
            )
            .animation(.easeInOut(duration: 0.19), value: isActive)
    }
}

// MARK: - Convenience View Extensions

extension View {
    func glassCard(
        cornerRadius: CGFloat = AppTheme.CornerRadius.large,
        borderColor: Color = AppTheme.Colors.cardBorder,
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(AppTheme.Modifiers.glassCard(
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }

    func materialBackground(
        cornerRadius: CGFloat = AppTheme.CornerRadius.large,
        material: Material = .ultraThinMaterial
    ) -> some View {
        modifier(AppTheme.Modifiers.materialBackground(
            cornerRadius: cornerRadius,
            material: material
        ))
    }

    func gradientText(_ gradient: LinearGradient) -> some View {
        modifier(AppTheme.Modifiers.gradientText(gradient))
    }

    func filterChip(
        accentColor: Color,
        isActive: Bool = false,
        cornerRadius: CGFloat = AppTheme.CornerRadius.large
    ) -> some View {
        modifier(AppTheme.Modifiers.filterChip(
            accentColor: accentColor,
            isActive: isActive,
            cornerRadius: cornerRadius
        ))
    }
}
