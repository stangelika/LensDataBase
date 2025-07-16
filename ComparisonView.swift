// ComparisonView.swift

import SwiftUI

struct ComparisonView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    // Получаем полные модели объективов для сравнения
    private var lensesToCompare: [Lens] {
        dataManager.comparisonSet.compactMap { lensId in
            dataManager.availableLenses.first { $0.id == lensId }
        }.sorted { $0.display_name < $1.display_name }
    }

    // Определяем строки нашей таблицы: Название и Ключевой путь к свойству
    private let specs: [(String, KeyPath<Lens, String>)] = [
        ("Format", \.format),
        ("Focal Length", \.focal_length),
        ("Aperture", \.aperture),
        ("Image Circle", \.image_circle),
        ("Close Focus", \.close_focus_cm),
        ("Front Diameter", \.front_diameter),
        ("Length", \.length),
        ("Weight (g)", \.weight_g),
        ("Mount", \.mount),
        ("Squeeze", \.squeeze_factor!) // Используем ! т.к. в модели он опционал
    ]

    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                    Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Шапка с кнопкой назад и заголовком
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Text("Comparison")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()

                // Если нет объективов для сравнения
                if lensesToCompare.isEmpty {
                    Spacer()
                    Text("Add lenses from their detail pages to compare.")
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    // --- ОСНОВНАЯ СТРУКТУРА ТАБЛИЦЫ ---
                    HStack(alignment: .top, spacing: 0) {
                        
                        // СТОЛБЕЦ 1: Закрепленные заголовки характеристик
                        VStack(alignment: .leading, spacing: 0) {
                            // Пустая ячейка для выравнивания
                            HeaderCell(text: "Feature")
                            
                            // Названия характеристик
                            ForEach(specs, id: \.0) { spec in
                                SpecNameCell(name: spec.0)
                            }
                        }
                        .frame(width: 140) // Фиксированная ширина для первого столбца
                        .zIndex(1) // Помещаем поверх прокручиваемого контента
                        
                        // СТОЛБЦЫ 2, 3, ...: Прокручиваемые данные объективов
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(lensesToCompare) { lens in
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Заголовок с названием объектива
                                        HeaderCell(text: lens.display_name)
                                        
                                        // Данные по каждой характеристике
                                        ForEach(specs, id: \.0) { spec in
                                            // Используем KeyPath для доступа к данным
                                            let value = lens[keyPath: spec.1]
                                            SpecValueCell(value: value.isEmpty ? "-" : value)
                                        }
                                    }
                                    .frame(width: 150) // Фиксированная ширина для каждого столбца данных
                                }
                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
    }
}


// --- Компоненты для ячеек таблицы ---

// Ячейка для заголовка (название фичи или объектива)
struct HeaderCell: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.headline.weight(.heavy))
            .foregroundColor(.white)
            .padding(12)
            .frame(height: 80) // Фиксированная высота для заголовков
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
    }
}

// Ячейка для названия характеристики
struct SpecNameCell: View {
    let name: String
    var body: some View {
        Text(name)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white.opacity(0.8))
            .padding(12)
            .frame(height: 50) // Фиксированная высота для строк
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .overlay(Divider(), alignment: .bottom) // Разделитель
    }
}

// Ячейка для значения характеристики
struct SpecValueCell: View {
    let value: String
    var body: some View {
        Text(value)
            .font(.system(.subheadline, design: .monospaced))
            .foregroundColor(.white)
            .padding(12)
            .frame(height: 50) // Фиксированная высота для строк
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08))
            .overlay(Divider(), alignment: .bottom) // Разделитель
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

// Разделитель для таблицы
struct Divider: View {
    var body: some View {
        Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.1))
    }
}