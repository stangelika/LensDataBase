import SwiftUI

// Экран отображения всех доступных объективов с фильтрацией и поиском
struct AllLensesView: View {
    // Менеджер данных для доступа к объективам и функциональности
    @EnvironmentObject var dataManager: DataManager
    // Выбранный формат для фильтрации объективов
    @State private var selectedFormat: String = ""
    // Выбранная категория фокусного расстояния
    @State private var selectedFocalCategory: FocalCategory = .all
    // Выбранный объектив для детального просмотра
    @State private var selectedLens: Lens? = nil

    // Основное содержимое экрана
    var body: some View {
        // Контейнер с фоновым градиентом
        ZStack {
            // Темный градиентный фон с синими оттенками
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 24 / 255, green: 27 / 255, blue: 37 / 255, opacity: 1),
                    Color(.sRGB, red: 34 / 255, green: 37 / 255, blue: 57 / 255, opacity: 1),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Основная вертикальная компоновка элементов
            VStack(spacing: 20) {
                // Заголовок секции с градиентным стилем
                HStack {
                    Text("Lenses")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .purple.opacity(0.85), .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 22)

                // Горизонтальная панель фильтров
                HStack(spacing: 16) {
                    // Выпадающее меню выбора формата съемки
                    Menu {
                        Picker("Format", selection: $selectedFormat) {
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
                            title: selectedFormat.isEmpty ? "All Formats" : selectedFormat,
                            accentColor: selectedFormat.isEmpty ? .purple : .green,
                            isActive: !selectedFormat.isEmpty
                        )
                    }

                    // Выпадающее меню выбора категории фокусного расстояния
                    Menu {
                        Picker("Focal Length Category", selection: $selectedFocalCategory) {
                            // Перебор всех доступных категорий фокусного расстояния
                            ForEach(FocalCategory.allCases, id: \.self) { cat in
                                Text(cat.displayName).tag(cat)
                            }
                        }
                    } label: {
                        // Кнопка фильтрации по фокусному расстоянию
                        GlassFilterChip(
                            icon: "arrow.left.and.right",
                            title: selectedFocalCategory.displayName,
                            accentColor: selectedFocalCategory == .all ? .indigo : .orange,
                            isActive: selectedFocalCategory != .all
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 2)

                // Основная область контента с условным отображением
                if dataManager.loadingState == .loading {
                    // Индикатор загрузки при получении данных
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.subheadline)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if dataManager.availableLenses.isEmpty {
                    // Сообщение об отсутствии данных
                    VStack(spacing: 8) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.system(size: 54))
                            .foregroundColor(.purple.opacity(0.4))
                        Text("No lenses available")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Главный компонент отображения списка объективов с примененными фильтрами
                    WeatherStyleLensListView(
                        format: selectedFormat,
                        focalCategory: selectedFocalCategory
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
        HStack(spacing: 8) {
            // Иконка фильтра с цветовой индикацией
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 17, weight: .semibold))
            // Текст названия фильтра
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 2)
            // Индикатор выпадающего меню
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 18)
        .background(
            // Многослойный фон с материальным эффектом
            ZStack {
                // Базовая стеклянная подложка
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .blur(radius: 0.6)
                // Цветная обводка с адаптивной яркостью
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isActive ? accentColor.opacity(0.7) : accentColor.opacity(0.28), lineWidth: isActive ? 2.3 : 1.3)
            }
        )
        // Тень с адаптивной интенсивностью
        .shadow(color: accentColor.opacity(isActive ? 0.20 : 0.07), radius: isActive ? 9 : 3, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .animation(.easeInOut(duration: 0.19), value: isActive)
    }
}
