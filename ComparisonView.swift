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
                        .font(.title.weight(.bold))
                    Spacer()
                    // Кнопка закрытия экрана сравнения
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline.weight(.semibold))
                }
                .padding()
                .foregroundColor(AppTheme.Colors.primaryText)

                // Основная область с таблицей сравнения
                ScrollView {
                    // Главный горизонтальный контейнер с фиксированной и прокручиваемой частями
                    HStack(alignment: .top, spacing: 0) {
                        // Фиксированная левая колонка с названиями характеристик
                        VStack(alignment: .leading, spacing: 0) {
                            // Заголовок колонки характеристик
                            Text("Feature")
                                .font(.appHeadline.weight(.bold))
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(AppTheme.Spacing.lg)
                                .frame(height: 120, alignment: .leading)
                                .background(AppTheme.Colors.toolbarBackground)

                            // Список названий характеристик для сравнения
                            ForEach(specs, id: \.0) { spec in
                                Text(spec.0)
                                    .font(.appBodyMedium)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                    .padding(AppTheme.Spacing.lg)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 60)
                                    // Альтернирующий фон для строк
                                    .background((specs.firstIndex(where: { $0.0 == spec.0 }) ?? 0) % 2 == 0 ? AppTheme.Colors.unselectedCardBackground : Color.clear)
                            }
                        }
                        .frame(width: 140)

                        // Горизонтально прокручиваемая область с колонками объективов
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                // Перебор всех объективов для сравнения
                                ForEach(lensesToCompare) { lens in
                                    // Колонка данных для одного объектива
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Заголовочная карточка с информацией об объективе
                                        VStack(alignment: .leading) {
                                            Text(lens.display_name)
                                                .font(.appHeadline.weight(.bold))
                                                .lineLimit(3)
                                            Text(lens.manufacturer)
                                                .font(.caption)
                                                .opacity(0.7)
                                        }
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                        .padding(AppTheme.Spacing.lg)
                                        .frame(width: 150, height: 120, alignment: .leading)
                                        .background(AppTheme.Colors.toolbarBackground)

                                        // Столбец значений характеристик объектива
                                        ForEach(specs, id: \.0) { spec in
                                            // Значение характеристики, извлеченное через KeyPath
                                            Text(lens[keyPath: spec.1])
                                                .font(.appMonospace)
                                                .foregroundColor(AppTheme.Colors.primaryText)
                                                .padding(AppTheme.Spacing.lg)
                                                .frame(width: 150, height: 60, alignment: .leading)
                                                // Альтернирующий фон для строк
                                                .background((specs.firstIndex(where: { $0.0 == spec.0 }) ?? 0) % 2 == 0 ? AppTheme.Colors.unselectedCardBackground : Color.clear)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        // Принудительная темная тема
        .preferredColorScheme(.dark)
    }
}
