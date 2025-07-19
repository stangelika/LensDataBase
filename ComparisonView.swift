// ComparisonView.swift

import SwiftUI

// Экран сравнения выбранных объективов в табличном формате
struct ComparisonView: View {
    // Менеджер данных для доступа к выбранным объективам
    @EnvironmentObject var dataManager: DataManager
    // Доступ к методу закрытия модального окна
    @Environment(\.presentationMode) var presentationMode

    // Вычисляемое свойство: получение полных моделей объективов из ID
    private var lensesToCompare: [Lens] {
        dataManager.comparisonSet.compactMap { lensId in
            dataManager.availableLenses.first { $0.id == lensId }
        }
        .sorted { $0.display_name < $1.display_name } // Сортируем для постоянства порядка
    }

    // Массив характеристик для сравнения с их KeyPath'ами
    private let specs: [(String, KeyPath<Lens, String>)] = [
        ("Format", \.format),
        ("Focal Length", \.focal_length),
        ("Aperture", \.aperture),
        ("Image Circle", \.image_circle),
        ("Close Focus", \.close_focus_cm),
        ("Front Diameter", \.front_diameter),
        ("Length", \.length),
    ]

    // Основное содержимое экрана
    var body: some View {
        ZStack {
            // Темный градиентный фон
            AppTheme.Colors.primaryGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Заголовочная область с кнопкой закрытия
                HStack {
                    Text("Comparison")
                        .font(.appTitle.weight(.bold)) // Используем шрифт из темы
                        .gradientText(AppTheme.Colors.favoriteTitleGradient) // Градиент как на экране избранного

                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.appHeadline.weight(.bold))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
                .padding()
                .foregroundColor(AppTheme.Colors.primaryText)

                // Основная область с таблицей сравнения
                ScrollView {
                    // Главный горизонтальный контейнер
                    HStack(alignment: .top, spacing: 0) {
                        // Фиксированная левая колонка с названиями характеристик
                        VStack(alignment: .leading, spacing: 0) {
                            // Заголовок колонки
                            Text("Feature")
                                .font(.appHeadline.weight(.bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(AppTheme.Spacing.lg)
                                .frame(height: 120, alignment: .leading)

                            // Список названий характеристик
                            ForEach(specs, id: \.0) { spec in
                                Text(spec.0)
                                    .font(.appBodyMedium)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                    .padding(AppTheme.Spacing.lg)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 60)
                            }
                        }
                        .frame(width: 140)
                        .glassCard(cornerRadius: AppTheme.CornerRadius.medium) // Применяем стиль GlassCard

                        // Горизонтально прокручиваемая область с колонками объективов
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: AppTheme.Spacing.lg) {
                                ForEach(lensesToCompare) { lens in
                                    // Колонка данных для одного объектива
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Заголовочная ячейка с названием объектива
                                        ComparisonCell(
                                            text: "\(lens.display_name)\n\(lens.manufacturer)",
                                            isHeader: true
                                        )

                                        // Ячейки со значениями характеристик
                                        ForEach(specs, id: \.0) { spec in
                                            ComparisonCell(text: lens[keyPath: spec.1])
                                        }
                                    }
                                    .glassCard(cornerRadius: AppTheme.CornerRadius.medium) // Применяем стиль GlassCard
                                }
                            }
                            .padding(.leading, AppTheme.Spacing.lg)
                        }
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Переиспользуемый компонент для ячеек таблицы сравнения
struct ComparisonCell: View {
    let text: String
    var isHeader: Bool = false // Флаг для стилизации заголовка

    var body: some View {
        Text(text)
            .font(isHeader ? .appHeadline.weight(.bold) : .appMonospace)
            .foregroundColor(AppTheme.Colors.primaryText)
            .padding(AppTheme.Spacing.lg)
            .frame(width: 150, height: isHeader ? 120 : 60, alignment: .leading)
            .background(isHeader ? AppTheme.Colors.toolbarBackground : Color.clear)
            .lineLimit(isHeader ? 3 : 2)
    }
}
