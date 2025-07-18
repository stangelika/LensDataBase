// ComparisonView.swift

import SwiftUI

struct ComparisonView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    // Получаем полные модели объективов из ID в сете для сравнения
    private var lensesToCompare: [Lens] {
        dataManager.comparisonSet.compactMap { lensId in
            dataManager.availableLenses.first { $0.id == lensId }
        }
        .sorted { $0.display_name < $1.display_name } // Сортируем для постоянства
    }
    
    // Определяем строки нашей таблицы
    private let specs: [(String, KeyPath<Lens, String>)] = [
        ("Format", \.format),
        ("Focal Length", \.focal_length),
        ("Aperture", \.aperture),
        ("Image Circle", \.image_circle),
        ("Close Focus", \.close_focus_cm),
        ("Front Diameter", \.front_diameter),
        ("Length", \.length)
    ]
    
    var body: some View {
        ZStack {
            // Use AppTheme background gradient
            AppTheme.Gradients.primary
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header with AppTheme styling
                HStack {
                    Text("Comparison")
                        .displayTextStyle()
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .headlineTextStyle()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
                
                // Main content with table in a glass card
                GlassCard {
                    ScrollView {
                        // Main HStack for sticky column and scroll area
                        HStack(alignment: .top, spacing: 0) {
                            
                            // Sticky column with feature names
                            VStack(alignment: .leading, spacing: 0) {
                                // Header for alignment
                                Text("Feature")
                                    .font(AppTheme.Typography.headlineMedium)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .padding(AppTheme.Spacing.sm)
                                    .frame(height: 120, alignment: .leading)
                                    .background(AppTheme.Colors.surfacePrimary)
                                
                                // Feature names
                                ForEach(specs, id: \.0) { spec in
                                    Text(spec.0)
                                        .font(AppTheme.Typography.bodyMedium)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .padding(AppTheme.Spacing.sm)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .frame(height: 60)
                                        .background(isEvenRow(spec.0) ? AppTheme.Colors.surfaceSecondary : Color.clear)
                                }
                            }
                            .frame(width: 140)
                            
                            // Horizontal scroll with lens columns
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    ForEach(lensesToCompare) { lens in
                                        // One column for each lens
                                        VStack(alignment: .leading, spacing: 0) {
                                            // Lens name card
                                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                                Text(lens.display_name)
                                                    .font(AppTheme.Typography.headlineMedium)
                                                    .lineLimit(3)
                                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                                Text(lens.manufacturer)
                                                    .font(AppTheme.Typography.caption)
                                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                            }
                                            .padding(AppTheme.Spacing.sm)
                                            .frame(width: 150, height: 120, alignment: .leading)
                                            .background(AppTheme.Colors.surfacePrimary)
                                            
                                            // Feature values
                                            ForEach(specs, id: \.0) { spec in
                                                Text(lens[keyPath: spec.1])
                                                    .font(AppTheme.Typography.bodyMedium)
                                                    .fontDesign(.monospaced)
                                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                                    .padding(AppTheme.Spacing.sm)
                                                    .frame(width: 150, height: 60, alignment: .leading)
                                                    .background(isEvenRow(spec.0) ? AppTheme.Colors.surfaceSecondary : Color.clear)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Helper function to determine if a row is even for alternating colors
    private func isEvenRow(_ specName: String) -> Bool {
        return (specs.firstIndex(where: { $0.0 == specName }) ?? 0) % 2 == 0
    }
}