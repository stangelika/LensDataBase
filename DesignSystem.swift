import SwiftUI

// MARK: - Design System for LensDataBase iPad App

struct DesignSystem {
    
    // MARK: - Spacing System
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 40
        
        // iPad-specific spacing
        static let contentInsets: CGFloat = 24
        static let sectionSpacing: CGFloat = 32
        static let cardSpacing: CGFloat = 16
        static let headerSpacing: CGFloat = 28
    }
    
    // MARK: - Corner Radius System
    enum CornerRadius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Typography System
    enum Typography {
        static let largeTitle = Font.system(size: 36, weight: .heavy, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 14, weight: .medium, design: .rounded)
        static let caption2 = Font.system(size: 12, weight: .regular, design: .rounded)
    }
    
    // MARK: - Color System
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.purple
        static let accent = Color.orange
        static let success = Color.green
        static let warning = Color.yellow
        static let error = Color.red
        static let surface = Color.white.opacity(0.07)
        static let surfaceElevated = Color.white.opacity(0.1)
        static let border = Color.white.opacity(0.1)
        static let borderActive = Color.white.opacity(0.3)
    }
    
    // MARK: - Gradients
    enum Gradients {
        static let primaryBackground = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let secondaryBackground = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 30/255, green: 32/255, blue: 54/255, opacity: 1),
                Color(.sRGB, red: 22/255, green: 22/255, blue: 32/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let splashBackground = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 28/255, green: 32/255, blue: 48/255, opacity: 1),
                Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255, opacity: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let detailBackground = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 27/255, green: 29/255, blue: 48/255, opacity: 1),
                Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let textPrimary = LinearGradient(
            colors: [.white, .blue.opacity(0.92)],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let textSecondary = LinearGradient(
            colors: [.white, .purple.opacity(0.85), .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let textAccent = LinearGradient(
            colors: [.white, .yellow.opacity(0.85), .orange],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let buttonPrimary = LinearGradient(
            colors: [.cyan, .blue.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Shadows
    enum Shadows {
		// Создаем псевдоним для типа тени, чтобы не повторять код
		typealias ShadowStyle = (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)

		static let sm: ShadowStyle = (color: .black.opacity(0.1), radius: 2.0, x: 0.0, y: 1.0)
		static let md: ShadowStyle = (color: .black.opacity(0.15), radius: 4.0, x: 0.0, y: 2.0)
		static let lg: ShadowStyle = (color: .black.opacity(0.2), radius: 8.0, x: 0.0, y: 4.0)
		static let xl: ShadowStyle = (color: .black.opacity(0.25), radius: 16.0, x: 0.0, y: 8.0)
    
		// Colored shadows
		static let primaryGlow: ShadowStyle = (color: .blue.opacity(0.3), radius: 10.0, x: 0.0, y: 5.0)
		static let accentGlow: ShadowStyle = (color: .orange.opacity(0.3), radius: 10.0, x: 0.0, y: 5.0)
		static let successGlow: ShadowStyle = (color: .green.opacity(0.3), radius: 10.0, x: 0.0, y: 5.0)
    }
    
    // MARK: - ✅ Custom Button Styles (ДОБАВЛЕНО)
    struct CapsuleButtonStyle: ButtonStyle {
        var backgroundColor: Color
        var foregroundColor: Color

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(DesignSystem.Typography.headline)
                // Используем ваши значения из Spacing
                .padding(.vertical, DesignSystem.Spacing.xs) 
                .padding(.horizontal, DesignSystem.Spacing.md)
                .foregroundColor(foregroundColor)
                .background(backgroundColor.opacity(0.25)) // Сделал чуть ярче
                .clipShape(Capsule())
                // Эффект нажатия
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

// MARK: - Design System Extensions

extension View {
    func designSystemShadow(_ shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
    
    func glassCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
}