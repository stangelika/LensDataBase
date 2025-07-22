import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLens: Lens? = nil
    @State private var isSelectionMode = false
    @State private var showComparisonSheet = false

    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Favorites")
                        .font(.appLargeTitle)
                        .gradientText(AppTheme.Colors.favoriteTitleGradient)
                        .shadow(color: AppTheme.Colors.yellow.opacity(0.18), radius: 12, x: 0, y: 6)

                    Spacer()

                    if !dataManager.favoriteLensesList.isEmpty {
                        Button(action: {
                            withAnimation {
                                isSelectionMode.toggle()
                            }
                            if !isSelectionMode {
                                dataManager.clearComparison()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "square.on.square")
                                    .font(.system(size: 16, weight: .bold))
                                Text(isSelectionMode ? "Done" : "Select")
                                    .font(.appHeadline.weight(.semibold))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .background(AppTheme.Colors.yellow.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                    .stroke(AppTheme.Colors.yellow.opacity(0.4), lineWidth: 1.5)
                            )
                            .shadow(color: AppTheme.Colors.yellow.opacity(0.3), radius: 8, y: 4)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)
                .padding(.bottom, AppTheme.Spacing.xxl)

                if dataManager.favoriteLensesList.isEmpty {
                    Spacer()
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "star.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.yellow.opacity(0.6))
                        Text("No Favorites Yet")
                            .font(.title2.weight(.bold))
                        Text("Tap the star on a lens's detail page to add it to your favorites.")
                            .font(.appBody)
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.xl) {
                            ForEach(dataManager.favoriteLensesList) { lens in
                                Button(action: {
                                    if isSelectionMode {
                                        dataManager.toggleComparison(lens: lens)
                                    } else {
                                        selectedLens = lens
                                    }
                                }) {
                                    LensRow(
                                        lens: lens,
                                        isSelectionMode: isSelectionMode,
                                        isSelectedForComparison: dataManager.isInComparison(lens: lens)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }

            .sheet(item: $selectedLens) { lens in
                LensDetailView(lens: lens)
                    .environmentObject(dataManager)
            }

            if isSelectionMode, dataManager.comparisonSet.count > 1 {
                VStack {
                    Spacer()
                    Button(action: {
                        showComparisonSheet = true
                    }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 18, weight: .bold))
                            Text("Compare (\(dataManager.comparisonSet.count))")
                                .font(.appHeadline.weight(.semibold))
                        }
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 26)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xlarge, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xlarge)
                                .stroke(AppTheme.Colors.blue.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: AppTheme.Colors.blue.opacity(0.3), radius: 10, y: 6)
                        .padding(.horizontal, AppTheme.Spacing.xxxl)
                    }
                    .padding(.bottom, (UIDevice.current.userInterfaceIdiom == .pad ? AppTheme.Spacing.xxxl : 0) + 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showComparisonSheet, onDismiss: {
            dataManager.clearComparison()
            isSelectionMode = false
        }) {
            ComparisonView().environmentObject(dataManager)
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: isSelectionMode)
        .animation(.easeInOut, value: dataManager.comparisonSet.count > 1)
    }
}
struct LensRow: View {
    let lens: Lens
    let isSelectionMode: Bool
    let isSelectedForComparison: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.padding15) {
            if isSelectionMode {
                Image(systemName: isSelectedForComparison ? "checkmark.circle.fill": "circle")
                    .font(.title2)
                    .foregroundColor(isSelectedForComparison ? AppTheme.Colors.blue: AppTheme.Colors.captionText)
            }
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(lens.display_name)
                    .font(.appHeadline.weight(.bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                Text("\(lens.manufacturer) • \(lens.format)")
                    .font(.appBody)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            Spacer()

            if !isSelectionMode {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.disabledText)
            }

        }
        .padding()
        .background(
            ZStack {
                Color.white.opacity(isSelectedForComparison ? 0.15: 0.05)
                if isSelectedForComparison {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.blue, lineWidth: 2)
                }

            }
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        .animation(.easeInOut(duration: 0.2), value: [isSelectionMode, isSelectedForComparison])
    }

}
