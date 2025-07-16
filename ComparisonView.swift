// ComparisonView.swift

import SwiftUI

struct ComparisonView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    // Получаем полные модели объективов
    private var lensesToCompare: [Lens] {
        dataManager.comparisonSet.compactMap { lensId in
            dataManager.availableLenses.first { $0.id == lensId }
        }
        .sorted { $0.display_name < $1.display_name }
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
                    Color(.sRGB, red: 28/255, green: 32/255, blue: 48/255),
                    Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255)
                ]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Шапка
                HStack {
                    Text("Comparison")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.cyan)
                }
                .padding()
                
                // Основной контент
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Горизонтальный список названий объективов
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(lensesToCompare) { lens in
                                    LensTitleCard(lens: lens)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Вертикальный список характеристик для сравнения
                        VStack(spacing: 16) {
                            ForEach(specs, id: \.0) { spec in
                                SpecComparisonRow(
                                    title: spec.0,
                                    values: lensesToCompare.map { $0[keyPath: spec.1] }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


// --- НОВЫЕ КОМПОНЕНТЫ ДЛЯ РЕДИЗАЙНА ---

// Карточка с названием объектива вверху
struct LensTitleCard: View {
    let lens: Lens
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lens.display_name)
                .font(.headline.weight(.bold))
                .lineLimit(2)
                .foregroundColor(.white)
            
            Text(lens.manufacturer)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(width: 160, height: 90)
        .background(GlassBackground())
    }
}

// Строка для сравнения одной характеристики
struct SpecComparisonRow: View {
    let title: String
    let values: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(values, id: \.self) { value in
                        Text(value.isEmpty ? "-" : value)
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 160, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(GlassBackground())
    }
}

