// GlassFilterChip.swift

import SwiftUI

/// A reusable glass filter chip component for filtering options
struct GlassFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    init(
        title: String,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.labelMedium)
                .fontWeight(.medium)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AppTheme.Animations.springFast, value: isSelected)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return AppTheme.Colors.accent.opacity(0.8)
        } else {
            return AppTheme.Colors.surfacePrimary
        }
    }
    
    private var foregroundColor: Color {
        return AppTheme.Colors.textPrimary
    }
    
    private var borderColor: Color {
        if isSelected {
            return AppTheme.Colors.accent
        } else {
            return AppTheme.Colors.glassBorder
        }
    }
    
    private var borderWidth: CGFloat {
        return isSelected ? 2 : 1
    }
}

// MARK: - Preview

struct GlassFilterChip_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.Gradients.primary
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.lg) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    GlassFilterChip(title: "All", isSelected: true) {
                        print("All tapped")
                    }
                    
                    GlassFilterChip(title: "Full Frame", isSelected: false) {
                        print("Full Frame tapped")
                    }
                    
                    GlassFilterChip(title: "Super35", isSelected: false) {
                        print("Super35 tapped")
                    }
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}