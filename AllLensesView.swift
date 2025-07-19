import SwiftUI

// Экран отображения всех доступных объективов с фильтрацией и поиском
struct AllLensesView: View {
    // Менеджер данных для доступа к объективам и функциональности
    @EnvironmentObject var dataManager: DataManager
    // Выбранный объектив для детального просмотра
    @State private var selectedLens: Lens? = nil
    
    // УДАЛЕНО: @State private var selectedFormat: String = ""
    // УДАЛЕНО: @State private var selectedFocalCategory: FocalCategory = .all
    // УДАЛЕНО: @State private var showOnlyRentable: Bool = true

    // Основное содержимое экрана
    var body: some View {
        // Контейнер с фоновым градиентом
        ZStack {
            // Темный градиентный фон с синими оттенками
            AppTheme.Colors.primaryGradient
                .ignoresSafeArea()

            // Основная вертикальная компоновка элементов
            VStack(spacing: AppTheme.Spacing.xxl) {
                // Заголовок секции с градиентным стилем
                HStack {
                    Text("Lenses")
                        .font(.appLargeTitle)
                        .gradientText(AppTheme.Colors.titleGradient)
                        .shadow(color: AppTheme.Colors.purple.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                // Горизонтальная панель фильтров
                HStack(spacing: AppTheme.Spacing.xl) {
                    // Выпадающее меню выбора формата съемки
                    Menu {
                        Picker("Format", selection: $dataManager.allLensesSelectedFormat) { // Привязка к DataManager
                            Text("All Formats").tag("")
                            // Динамический список доступных форматов из данных
                            ForEach(Array(Set(dataManager.availableLenses.map(\.format))).sorted(), id: \.self) { format in
                                Text(format).tag(format)
                            }
                        }
                    } label: {
                        // Кнопка фильтрации по формату с визуальной обратной связью
                        GlassFilterChip(
                            icon: "crop",
                            title: dataManager.allLensesSelectedFormat.isEmpty ? "All Formats" : dataManager.allLensesSelectedFormat,
                            accentColor: dataManager.allLensesSelectedFormat.isEmpty ? AppTheme.Colors.purple : AppTheme.Colors.green,
                            isActive: !dataManager.allLensesSelectedFormat.isEmpty
                        )
                    }

                    // Выпадающее меню выбора категории фокусного расстояния
                    Menu {
                        Picker("Focal Length Category", selection: $dataManager.allLensesSelectedFocalCategory) { // Привязка к DataManager
                            // Перебор всех доступных категорий фокусного расстояния
                            ForEach(FocalCategory.allCases, id: \.self) { cat in
                                Text(cat.displayName).tag(cat)
                            }
                        }
                    } label: {
                        // Кнопка фильтрации по фокусному расстоянию
                        GlassFilterChip(
                            icon: "arrow.left.and.right",
                            title: dataManager.allLensesSelectedFocalCategory.displayName,
                            accentColor: dataManager.allLensesSelectedFocalCategory == .all ? AppTheme.Colors.indigo : AppTheme.Colors.orange,
                            isActive: dataManager.allLensesSelectedFocalCategory != .all
                        )
                    }
                    
                    // НОВЫЙ UI-ЭЛЕМЕНТ: Кнопка-тумблер для фильтра "только в аренде"
                    Button(action: {
                        withAnimation {
                            dataManager.allLensesShowOnlyRentable.toggle() // Привязка к DataManager
                        }
                    }) {
                        GlassFilterChip(
                            icon: "building.2",
                            title: "In Rental",
                            accentColor: AppTheme.Colors.blue,
                            isActive: dataManager.allLensesShowOnlyRentable
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.padding24)
                .padding(.bottom, AppTheme.Spacing.xs)

                // Основная область контента с условным отображением
                if dataManager.loadingState == .loading {
                    // Индикатор загрузки при получении данных
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.purple))
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .foregroundColor(AppTheme.Colors.quaternaryText)
                            .font(.appBody)
                            .padding(.top, AppTheme.Spacing.sm)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if dataManager.availableLenses.isEmpty {
                    // Сообщение об отсутствии данных
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.system(size: 54))
                            .foregroundColor(AppTheme.Colors.purple.opacity(0.4))
                        Text("No lenses available")
                            .font(.appHeadline)
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Главный компонент отображения списка объективов с примененными фильтрами
                    WeatherStyleLensListView(
                        lensesSource: dataManager.groupedAndFilteredLenses // Передаем уже готовые данные
                    ) { lens in
                        // Callback для открытия детального экрана объектива
                        selectedLens = lens
                    }
                }
            }
            .sheet(item: $selectedLens) { lens in
                // Модальное окно с подробной информацией об объективе
                LensDetailView(lens: lens)
                    .environmentObject(dataManager)
            }
        }
        // Принудительная темная тема
        .preferredColorScheme(.dark)
    }
}

// Перечисление категорий фокусного расстояния для фильтрации
enum FocalCategory: String, CaseIterable, Identifiable {
    case all
    case ultraWide
    case wide
    case standard
    case tele
    case superTele

    var id: String { rawValue }

    // Отображаемые названия категорий для UI
    var displayName: String {
        switch self {
        case .all: "All"
        case .ultraWide: "Ultra Wide (≤12mm)"
        case .wide: "Wide (13–35mm)"
        case .standard: "Standard (36–70mm)"
        case .tele: "Tele (71–180mm)"
        case .superTele: "Super Tele (181mm+)"
        }
    }

    // Проверка попадания фокусного расстояния в категорию
    func contains(focal: Double?) -> Bool {
        guard let focal else { return false }
        switch self {
        case .all: return true
        case .ultraWide: return focal <= 12
        case .wide: return focal >= 13 && focal <= 35
        case .standard: return focal >= 36 && focal <= 70
        case .tele: return focal >= 71 && focal <= 180
        case .superTele: return focal > 180
        }
    }
}

// Расширение модели Lens для извлечения численного значения фокусного расстояния
extension Lens {
    // Парсинг первого числового значения из строки фокусного расстояния
    var mainFocalValue: Double? {
        let numbers = focal_length
            .components(separatedBy: CharacterSet(charactersIn: "-– "))
            .compactMap { Double($0.filter("0123456789.".contains)) }
        return numbers.first
    }
}

// Стилизованная кнопка-фильтр с материальным дизайном и анимацией
struct GlassFilterChip: View {
    // Иконка фильтра
    let icon: String
    // Текст фильтра
    let title: String
    // Цвет акцента для подсветки
    let accentColor: Color
    // Состояние активности фильтра
    var isActive: Bool = false

    // Содержимое кнопки фильтра
    var body: some View {
        // Горизонтальная компоновка элементов кнопки
        HStack(spacing: AppTheme.Spacing.md) {
            // Иконка фильтра с цветовой индикацией
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 17, weight: .semibold))
            // Текст названия фильтра
            Text(title)
                .font(.appBodyMedium)
                .foregroundColor(AppTheme.Colors.primaryText)
                .lineLimit(1)
            Spacer(minLength: AppTheme.Spacing.xs)
            // Индикатор выпадающего меню
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.Colors.tertiaryText)
        }
        .padding(.vertical, AppTheme.Spacing.padding11)
        .padding(.horizontal, AppTheme.Spacing.padding18)
        .filterChip(accentColor: accentColor, isActive: isActive, cornerRadius: AppTheme.CornerRadius.large)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
}