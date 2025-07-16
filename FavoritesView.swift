// FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLens: Lens? = nil
    @State private var isSelectionMode = false
    @State private var showComparisonSheet = false

    var body: some View {
        // Main ZStack for floating button overlay
        ZStack {
            NavigationView {
                ZStack {
                    // Background
                    DesignSystem.Gradients.primaryBackground
                        .ignoresSafeArea()

                    // Main content
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Custom header
                        HStack {
                            Text("Favorites")
                                .font(DesignSystem.Typography.largeTitle)
                                .foregroundStyle(DesignSystem.Gradients.textAccent)
                                .designSystemShadow(DesignSystem.Shadows.md)
                            Spacer()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.headerSpacing)
                        .padding(.top, DesignSystem.Spacing.xxl)

                        // Check for empty favorites list
                        if dataManager.favoriteLensesList.isEmpty {
                            Spacer()
                            VStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: "star.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.yellow.opacity(0.6))
                                Text("No Favorites Yet")
                                    .font(DesignSystem.Typography.title2)
                                Text("Tap the star on a lens's detail page to add it to your favorites.")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, DesignSystem.Spacing.huge)
                            }
                            Spacer()
                            Spacer()
                        } else {
                            // List
                            ScrollView {
                                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                                    ForEach(dataManager.favoriteLensesList) { lens in
                                        Button(action: {
                                            if isSelectionMode {
                                                dataManager.toggleComparison(lens: lens)
                                            } else {
                                                self.selectedLens = lens
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
                                .padding(.horizontal, DesignSystem.Spacing.contentInsets)
                                .padding(.bottom, 100) // Bottom padding for floating button
                            }
                        }
                    }
                    .sheet(item: $selectedLens) { lens in
                        LensDetailView(lens: lens).environmentObject(dataManager)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !dataManager.favoriteLensesList.isEmpty {
                                Button(action: {
                                    withAnimation(.easeInOut) { isSelectionMode.toggle() }
                                    if !isSelectionMode { dataManager.clearComparison() }
                                }) {
                                    // --- ОБНОВЛЕННАЯ КНОПКА ---
                                    HStack(spacing: DesignSystem.Spacing.xs) {
                                        Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "square.and.arrow.down.on.square")
                                        Text(isSelectionMode ? "Done" : "Select")
                                    }
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(isSelectionMode ? .green : .cyan)
                                    .padding(.vertical, DesignSystem.Spacing.sm)
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .background(
                                        (isSelectionMode ? Color.green : Color.cyan).opacity(0.2)
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
            .preferredColorScheme(.dark)
            
            // Плавающая кнопка "Сравнить"
            if isSelectionMode && dataManager.comparisonSet.count > 1 {
                VStack {
                    Spacer()
                    Button(action: {
                        showComparisonSheet = true
                    }) {
                        Text("Compare (\(dataManager.comparisonSet.count)) Lenses")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                            .padding(DesignSystem.Spacing.lg)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(DesignSystem.CornerRadius.lg)
                            .designSystemShadow(DesignSystem.Shadows.primaryGlow)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.contentInsets)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: isSelectionMode)
        .animation(.easeInOut, value: dataManager.comparisonSet.count > 1)
        .sheet(isPresented: $showComparisonSheet, onDismiss: {
            dataManager.clearComparison()
            isSelectionMode = false
        }) {
            ComparisonView().environmentObject(dataManager)
        }
    }
}


// Строка списка (без изменений)
struct LensRow: View {
    let lens: Lens
    let isSelectionMode: Bool
    let isSelectedForComparison: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            if isSelectionMode {
                Image(systemName: isSelectedForComparison ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelectedForComparison ? .blue : .secondary)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(lens.display_name)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.white)
                Text("\(lens.manufacturer) • \(lens.format)")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            if !isSelectionMode {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            ZStack {
                Color.white.opacity(isSelectedForComparison ? 0.15 : 0.05)
                if isSelectedForComparison {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
        )
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .animation(.easeInOut(duration: 0.2), value: [isSelectionMode, isSelectedForComparison])
    }
}