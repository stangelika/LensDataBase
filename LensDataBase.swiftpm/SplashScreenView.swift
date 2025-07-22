import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var isActive = false

    @State private var logoPulse = false

    @State private var glassBlur = false

    @State private var showSubtitle = false

    @State private var shimmerPhase: CGFloat = 0
    
      @State private var splashMinimumDelayPassed = false

    var body: some View {
        if isActive {
            MainTabView()
        }
        else {
            ZStack {
                AppTheme.Colors.detailViewGradient
                .ignoresSafeArea()

                Circle()
                .fill(
                RadialGradient(
                gradient: Gradient(colors: [
                AppTheme.Colors.orange.opacity(0.28), AppTheme.Colors.purple.opacity(0.16), Color.clear, ]), center: .center, startRadius: 0, endRadius: 350
                )
                )
                .frame(width: 430, height: 430)
                .blur(radius: 2)
                .offset(x: -60, y: -120)

                VStack(spacing: 0) {
                    ZStack {
                        GlassCard()
                        .frame(width: 230, height: 230)
                        .opacity(glassBlur ? 1: 0)
                        .scaleEffect(glassBlur ? 1: 0.85)
                        .animation(.easeOut(duration: 0.7), value: glassBlur)

                        Image(systemName: "camera.aperture")
                        .font(.system(size: 88, weight: .bold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                        LinearGradient(
                        colors: [AppTheme.Colors.orange, AppTheme.Colors.yellow, AppTheme.Colors.purple.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing
                        ), AppTheme.Colors.primaryText
                        )
                        .shadow(color: AppTheme.Colors.orange.opacity(0.22), radius: 20, x: 0, y: 6)
                        .scaleEffect(logoPulse ? 1.07: 1)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: logoPulse)
                    }
                    .padding(.bottom, AppTheme.Spacing.md)

                    Text("Lens Data Base")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                    LinearGradient(
                    colors: [AppTheme.Colors.primaryText, AppTheme.Colors.yellow, AppTheme.Colors.orange, AppTheme.Colors.purple.opacity(0.95)], startPoint: .leading, endPoint: .trailing
                    )
                    )
                    .shadow(color: AppTheme.Colors.orange.opacity(0.09), radius: 5, x: 0, y: 3)
                    .opacity(showSubtitle ? 1: 0)
                    .offset(y: showSubtitle ? 0: 10)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: showSubtitle)

                    Text("Cinematic lens catalog & rentals")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.tertiaryText.opacity(0.65))
                    .padding(.top, AppTheme.Spacing.sm)
                    .opacity(showSubtitle ? 1: 0)
                    .offset(y: showSubtitle ? 0: 8)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: showSubtitle)
                }
                .padding(.top, AppTheme.Spacing.padding24)

                VStack {
                    Spacer()

                    GlassCard()
                    .frame(height: 80)
                    .overlay(
                    VStack(spacing: 10) {
                        if dataManager.loadingState    == .loading {
                            HStack(spacing: AppTheme.Spacing.lg) {
                                ProgressView()
                                .scaleEffect(1.1)
                                .tint(AppTheme.Colors.orange)
                                Text("Loading data...")
                                .font(.appBody)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            }

                        }
                        else if case let .error(error) = dataManager.loadingState {
                            Text("Error: \(error)")
                            .font(.footnote)
                            .foregroundColor(.red)
                        }
                        ShimmeringText(text: "Developed by Skvora007", phase: shimmerPhase)
                        .font(.system(.caption, design: .monospaced).weight(.medium))
                        .opacity(0.87)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 1)
                    }
                    .padding(.vertical, AppTheme.Spacing.md)
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, AppTheme.Spacing.padding36)
                }

            }
          
            
                .onAppear {dataManager.loadData()
                    
                    withAnimation(.easeInOut(duration: 1.4)) {
                        glassBlur = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        logoPulse = true
                        showSubtitle = true
                    }
                    
                    withAnimation(Animation.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                        shimmerPhase = 1.0
                    }
                    
                    // Минимальное время отображения Splash
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        splashMinimumDelayPassed = true
                        if dataManager.loadingState == .loaded {
                            withAnimation(.easeInOut(duration: 0.55)) {
                                isActive = true
                            }
                        }
                    }
                }
            
                .onChange(of: dataManager.loadingState) { oldState, newState in
                    if newState == .loaded, splashMinimumDelayPassed {
                        withAnimation(.easeInOut(duration: 0.55)) {
                            isActive = true
                        }
                    }
                }

        }

    }

}
struct GlassCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(.ultraThinMaterial)
        .shadow(color: AppTheme.Colors.primaryText.opacity(0.07), radius: 16, x: 0, y: 10)
        .background(

        RoundedRectangle(cornerRadius: 32)
        .stroke(AppTheme.Colors.cardBorder.opacity(0.13), lineWidth: 1.1)
        )
        .overlay(

        RoundedRectangle(cornerRadius: 32)
        .stroke(
        LinearGradient(
        colors: [AppTheme.Colors.orange.opacity(0.13), AppTheme.Colors.purple.opacity(0.09), .clear], startPoint: .topLeading, endPoint: .bottomTrailing
        ), lineWidth: 2
        )
        )
    }

}
struct ShimmeringText: View {
    let text: String

    var phase: CGFloat

    var body: some View {
        ZStack {
            Text(text)
            .foregroundColor(.white.opacity(0.5))

            Text(text)
            .foregroundColor(.white)
            .overlay(

            LinearGradient(
            gradient: Gradient(colors: [
            .white.opacity(0.15), .white.opacity(0.7), .white.opacity(0.15), ]), startPoint: .leading, endPoint: .trailing
            )
            .frame(width: 120, height: 12)
            .rotationEffect(.degrees(20))
            .offset(x: (phase * 200) - 100)
            .mask(Text(text))
            )
            .opacity(0.95)
        }
        .clipped()
        .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: phase)
    }

}
