import SwiftUI

// Компонент отображения списка объективов в стиле погодного приложения с фильтрацией
struct WeatherStyleLensListView: View {
    // Менеджер данных для доступа к объективам
    @EnvironmentObject var dataManager: DataManager
    // ID компании проката для фильтрации (опционально)
    let rentalId: String?
    // Фильтр по формату съемки
    let format: String
    // Фильтр по категории фокусного расстояния
    let focalCategory: FocalCategory
    // Callback для обработки выбора объектива
    let onSelect: (Lens) -> Void

    // Инициализатор с настройками фильтрации
    init(rentalId: String? = nil, format: String = "", focalCategory: FocalCategory = .all, onSelect: @escaping (Lens) -> Void) {
        self.rentalId = rentalId
        self.format = format
        self.focalCategory = focalCategory
        self.onSelect = onSelect
    }

    // Вычисляемое свойство: отфильтрованные группы объективов
    private var filteredGroups: [LensGroup] {
        let groups = dataManager.groupLenses(forRental: rentalId)
        // Если нет активных фильтров, возвращаем все группы
        guard !format.isEmpty || focalCategory != .all else { return groups }
        // Применяем фильтры к группам объективов
        return groups.compactMap { group in
            let filteredSeries = group.series.compactMap { series in
                let filteredLenses = series.lenses.filter {
                    // Фильтрация по формату и категории фокусного расстояния
                    (format.isEmpty || $0.format == format)
                        && focalCategory.contains(focal: $0.mainFocalValue)
                }
                return filteredLenses.isEmpty ? nil : LensSeries(name: series.name, lenses: filteredLenses)
            }
            return filteredSeries.isEmpty ? nil : LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
        }
    }

    // Основное содержимое компонента
    var body: some View {
        // Скроллируемый контейнер без индикаторов
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.padding36) {
                // Перебор всех отфильтрованных групп производителей
                ForEach(filteredGroups) { group in
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                        // Заголовок группы производителя
                        HStack {
                            Text(group.manufacturer)
                                .font(.appTitle2)
                                .gradientText(AppTheme.Colors.manufacturerGradient)
                                .shadow(color: AppTheme.Colors.blue.opacity(0.16), radius: 4, x: 0, y: 2)
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.xxxl)

                        // Перебор всех серий объективов производителя
                        ForEach(group.series) { series in
                            // Компонент отображения серии объективов в погодном стиле
                            WeatherStyleLensSeriesView(series: series, onSelect: onSelect)
                        }
                    }
                    .padding(.bottom, AppTheme.Spacing.xs)
                }
            }
            .padding(.top, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .background(
            // Темный градиентный фон для контрастности
            AppTheme.Colors.listViewGradient
                .ignoresSafeArea()
        )
    }
}

// Компонент отображения серии объективов с возможностью разворачивания
struct WeatherStyleLensSeriesView: View {
    // Данные серии объективов
    let series: LensSeries
    // Callback для обработки выбора объектива
    let onSelect: (Lens) -> Void
    // Состояние разворачивания списка объективов серии
    @State private var isExpanded: Bool = false

    // Содержимое компонента серии
    var body: some View {
        VStack(spacing: 0) {
            // Кнопка-заголовок серии с возможностью разворачивания
            Button(action: {
                // Анимированное переключение состояния разворачивания
                withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                // Содержимое кнопки-заголовка
                HStack {
                    // Название серии объективов
                    Text(series.name)
                        .font(.appHeadline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .lineLimit(1)
                    Spacer()
                    // Индикатор состояния разворачивания
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(AppTheme.Spacing.padding15)
                .background(
                    // Многослойный фон с материальным эффектом и адаптивной обводкой
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(
                                AppTheme.Colors.indigo.opacity(isExpanded ? 0.32 : 0.18),
                                lineWidth: isExpanded ? 2 : 1.2
                            )
                    }
                )
                // Тень с адаптивной интенсивностью
                .shadow(
                    color: AppTheme.Colors.blue.opacity(isExpanded ? 0.10 : 0.04),
                    radius: isExpanded ? 6 : 2,
                    x: 0,
                    y: 2
                )
                .padding(.horizontal, AppTheme.Spacing.padding22)
            }
            .buttonStyle(NoHighlightButtonStyle())

            // Условное отображение развернутого списка объективов
            if isExpanded {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Перебор всех объективов в серии
                    ForEach(series.lenses) { lens in
                        // Компонент строки объектива
                        WeatherStyleLensRow(lens: lens)
                            .onTapGesture {
                                // Обработка выбора объектива
                                onSelect(lens)
                            }
                            // Анимация появления/скрытия строки
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.padding30)
                .padding(.vertical, 7)
            }
        }
        // Плавная анимация изменения состояния разворачивания
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }
}

// Компонент строки объектива в погодном стиле
struct WeatherStyleLensRow: View {
    // Данные объектива для отображения
    let lens: Lens

    // Содержимое строки объектива
    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.padding18) {
            // Основная информация об объективе
            VStack(alignment: .leading, spacing: AppTheme.Spacing.padding6) {
                // Комбинированное отображение: название + фокусное расстояние
                Text("\(lens.lens_name) \(lens.focal_length)")
                    .font(.appRounded18)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .lineLimit(1)

                // Бейдж формата (только для Full Frame)
                if lens.format.contains("FF") {
                    HStack(spacing: AppTheme.Spacing.padding11) {
                        WeatherStyleLensBadge(
                            icon: "crop",
                            value: lens.format,
                            color: AppTheme.Colors.green
                        )
                    }
                }
            }

            Spacer()

            // Индикатор возможности перехода к деталям
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.Colors.disabledText)
                .font(.system(size: 18, weight: .medium))
        }
        .padding(.vertical, AppTheme.Spacing.padding14)
        .padding(.horizontal, AppTheme.Spacing.padding18)
        .background(
            // Многослойный фон с материальным эффектом
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.blue.opacity(0.15), lineWidth: 1)
            }
        )
        // Тонкая тень для глубины
        .shadow(color: AppTheme.Colors.blue.opacity(0.06), radius: 2, x: 0, y: 2)
        // Анимация появления/скрытия
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

// Компонент цветного бейджа для характеристик объектива
struct WeatherStyleLensBadge: View {
    // Иконка бейджа
    let icon: String
    // Текстовое значение
    let value: String
    // Цвет акцента
    let color: Color

    // Содержимое бейджа
    var body: some View {
        HStack(spacing: AppTheme.Spacing.padding6) {
            // Иконка характеристики
            Image(systemName: icon)
                .imageScale(.small)
                .foregroundColor(color)
            // Значение характеристики
            Text(value)
                .font(.appRounded14)
                .foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.horizontal, AppTheme.Spacing.padding11)
        .padding(.vertical, 5)
        .background(
            // Цветная капсульная подложка
            Capsule()
                .fill(color.opacity(0.19))
        )
    }
}

// Стиль кнопки без выделения при нажатии
struct NoHighlightButtonStyle: ButtonStyle {
    // Кастомная реализация стиля кнопки
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Легкое затемнение при нажатии
            .opacity(configuration.isPressed ? 0.82 : 1.0)
    }
}
