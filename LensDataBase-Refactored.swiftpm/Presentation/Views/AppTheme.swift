import SwiftUI

// MARK: - Modern Theme System

struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary gradient backgrounds
        static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let cardGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 30/255, green: 32/255, blue: 54/255, opacity: 1),
                Color(.sRGB, red: 22/255, green: 22/255, blue: 32/255, opacity: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let detailGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 27/255, green: 29/255, blue: 48/255, opacity: 1),
                Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Text gradients
        static let titleGradient = LinearGradient(
            colors: [.white, .purple.opacity(0.85), .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let accentGradient = LinearGradient(
            colors: [.green, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Semantic colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let cardBackground = Color(.systemGray6).opacity(0.3)
        
        static let primary = Color.blue
        static let secondary = Color.purple
        static let accent = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let success = Color.green
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(.systemGray)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let title = Font.system(.title, design: .rounded, weight: .semibold)
        static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
        static let title3 = Font.system(.title3, design: .rounded, weight: .medium)
        static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
        static let body = Font.system(.body, design: .rounded)
        static let callout = Font.system(.callout, design: .rounded)
        static let subheadline = Font.system(.subheadline, design: .rounded)
        static let footnote = Font.system(.footnote, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    }
}

// MARK: - View Extensions

extension View {
    func gradientText(_ gradient: LinearGradient) -> some View {
        self.overlay(gradient)
            .mask(self)
    }
    
    func appCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(
                color: AppTheme.Shadow.medium.color,
                radius: AppTheme.Shadow.medium.radius,
                x: AppTheme.Shadow.medium.x,
                y: AppTheme.Shadow.medium.y
            )
    }
    
    func appButton(style: AppButtonStyle = .primary) -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(style.background)
            .foregroundColor(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            .shadow(
                color: AppTheme.Shadow.small.color,
                radius: AppTheme.Shadow.small.radius,
                x: AppTheme.Shadow.small.x,
                y: AppTheme.Shadow.small.y
            )
    }
    
    func errorAlert(isPresented: Binding<Bool>, message: String?) -> some View {
        self.alert("Error", isPresented: isPresented) {
            Button("OK") { }
        } message: {
            Text(message ?? "An unknown error occurred")
        }
    }
}

// MARK: - Button Styles

enum AppButtonStyle {
    case primary
    case secondary
    case accent
    case warning
    case destructive
    
    var background: AnyView {
        switch self {
        case .primary:
            return AnyView(AppTheme.Colors.primary)
        case .secondary:
            return AnyView(AppTheme.Colors.secondary)
        case .accent:
            return AnyView(AppTheme.Colors.accentGradient)
        case .warning:
            return AnyView(AppTheme.Colors.warning)
        case .destructive:
            return AnyView(AppTheme.Colors.error)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .secondary, .accent, .warning, .destructive:
            return .white
        }
    }
}

// MARK: - Custom Components

struct GradientBackground: View {
    let gradient: LinearGradient
    
    var body: some View {
        gradient
            .ignoresSafeArea()
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.Colors.accent)
            
            Text(message)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.xxl)
        .appCard()
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.Spacing.xxl)
    }
}