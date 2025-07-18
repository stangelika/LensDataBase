import SwiftUI

/// A filter chip component for dropdown menu labels
struct FilterChip: View {
    let icon: String
    let title: String
    let accentColor: Color
    var isActive = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 17, weight: .semibold))
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 2)
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .blur(radius: 0.6)
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isActive ? accentColor.opacity(0.7) : accentColor.opacity(0.28),
                        lineWidth: isActive ? 2.3 : 1.3)
            })
        .shadow(color: accentColor.opacity(isActive ? 0.20 : 0.07), radius: isActive ? 9 : 3, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .animation(.easeInOut(duration: 0.19), value: isActive)
    }
}

// MARK: - Preview
struct FilterChip_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.Gradients.primary
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.lg) {
                FilterChip(
                    icon: "crop", 
                    title: "All Formats", 
                    accentColor: .purple,
                    isActive: false
                )
                
                FilterChip(
                    icon: "arrow.left.and.right",
                    title: "Wide Angle",
                    accentColor: .green,
                    isActive: true
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}