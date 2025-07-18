import SwiftUI

/// A reusable glass morphism card component
struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: CGFloat

    init(
        cornerRadius: CGFloat = AppTheme.CornerRadius.md,
        padding: CGFloat = AppTheme.Spacing.lg,
        @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .glassEffect(cornerRadius: cornerRadius)
            .shadow(color: AppTheme.Shadows.medium, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

struct GlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.Gradients.primary
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.lg) {
                GlassCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Sample Card")
                            .headlineTextStyle()
                        Text(
                            "This is a sample glass card component with some content to demonstrate the glass morphism effect.")
                            .secondaryTextStyle()
                    }
                }

                GlassCard(cornerRadius: AppTheme.CornerRadius.xl) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .foregroundColor(AppTheme.Colors.accent)
                        Text("Camera Lens")
                            .primaryTextStyle()
                        Spacer()
                        Text("f/1.4")
                            .secondaryTextStyle()
                    }
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
