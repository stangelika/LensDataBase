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
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                    Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Шапка с кнопкой "Done"
                HStack {
                    Text("Comparison")
                        .font(.title.weight(.bold))
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline.weight(.semibold))
                }
                .padding()
                .foregroundColor(.white)
                
                // Основной контент с таблицей
                ScrollView {
                    // Главный HStack, который держит "липкую" колонку и скролл-область
                    HStack(alignment: .top, spacing: 0) {
                        
                        // "Липкая" колонка с названиями характеристик
                        VStack(alignment: .leading, spacing: 0) {
                            // Пустой заголовок для выравнивания
                            Text("Feature")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .frame(height: 120, alignment: .leading)
                                .background(Color.white.opacity(0.1))
                            
                            // Названия характеристик
                            ForEach(specs, id: \.0) { spec in
                                Text(spec.0)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 60)
                                    .background( (specs.firstIndex(where: {$0.0 == spec.0}) ?? 0) % 2 == 0 ? Color.white.opacity(0.05) : Color.clear)
                            }
                        }
                        .frame(width: 140)
                        
                        // Горизонтальный скролл с колонками объективов
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(lensesToCompare) { lens in
                                    // Одна колонка для одного объектива
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Карточка с названием объектива
                                        VStack(alignment: .leading) {
                                            Text(lens.display_name)
                                                .font(.headline.weight(.bold))
                                                .lineLimit(3)
                                            Text(lens.manufacturer)
                                                .font(.caption)
                                                .opacity(0.7)
                                        }
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .frame(width: 150, height: 120, alignment: .leading)
                                        .background(Color.white.opacity(0.1))
                                        
                                        // Значения характеристик
                                        ForEach(specs, id: \.0) { spec in
                                            Text(lens[keyPath: spec.1])
                                                .font(.system(.subheadline, design: .monospaced))
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .frame(width: 150, height: 60, alignment: .leading)
                                                .background( (specs.firstIndex(where: {$0.0 == spec.0}) ?? 0) % 2 == 0 ? Color.white.opacity(0.05) : Color.clear)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}