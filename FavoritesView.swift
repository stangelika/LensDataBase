// FavoritesView.swift

import SwiftUI

// Экран избранных объективов с возможностью сравнения
struct FavoritesView: View {
    // Менеджер данных для доступа к избранным объективам
    @EnvironmentObject var dataManager: DataManager
    // Выбранный объектив для детального просмотра
    @State private var selectedLens: Lens? = nil
    // Режим выбора объективов для сравнения
    @State private var isSelectionMode = false
    // Состояние отображения экрана сравнения
    @State private var showComparisonSheet = false

    // Основное содержимое экрана
    var body: some View {
        // Контейнер для размещения плавающей кнопки поверх контента
        ZStack {
            NavigationView {
                ZStack {
                    // Темный градиентный фон
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.sRGB, red: 24 / 255, green: 27 / 255, blue: 37 / 255, opacity: 1),
                            Color(.sRGB, red: 34 / 255, green: 37 / 255, blue: 57 / 255, opacity: 1),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // Основная область контента
                    VStack(spacing: 20) {
                        // Заголовок секции с градиентным стилем
                        HStack {
                            Text("Favorites")
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: [.white, .yellow.opacity(0.85), .orange], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: .yellow.opacity(0.18), radius: 12, x: 0, y: 6)
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 22)

                        // Условное отображение при отсутствии избранных объективов
                        if dataManager.favoriteLensesList.isEmpty {
                            Spacer()
                            // Сообщение о пустом списке избранного
                            VStack(spacing: 12) {
                                Image(systemName: "star.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.yellow.opacity(0.6))
                                Text("No Favorites Yet")
                                    .font(.title2.weight(.bold))
                                Text("Tap the star on a lens's detail page to add it to your favorites.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                            Spacer()
                        } else {
                            // Скроллируемый список избранных объективов
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    // Перебор всех избранных объективов
                                    ForEach(dataManager.favoriteLensesList) { lens in
                                        Button(action: {
                                            // Обработка нажатия в зависимости от режима
                                            if isSelectionMode {
                                                // В режиме выбора добавляем/убираем из сравнения
                                                dataManager.toggleComparison(lens: lens)
                                            } else {
                                                // В обычном режиме открываем детали объектива
                                                selectedLens = lens
                                            }
                                        }) {
                                            // Компонент строки объектива с индикацией выбора
                                            LensRow(
                                                lens: lens,
                                                isSelectionMode: isSelectionMode,
                                                isSelectedForComparison: dataManager.isInComparison(lens: lens)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 100) // Отступ снизу для плавающей кнопки
                            }
                        }
                    }
                    .sheet(item: $selectedLens) { lens in
                        // Модальное окно с детальной информацией об объективе
                        LensDetailView(lens: lens).environmentObject(dataManager)
                    }
                    .toolbar {
                        // Кнопка переключения режима выбора в навигационной панели
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !dataManager.favoriteLensesList.isEmpty {
                                Button(action: {
                                    // Переключение режима выбора с анимацией
                                    withAnimation { isSelectionMode.toggle() }
                                    // Очистка сравнения при выходе из режима
                                    if !isSelectionMode { dataManager.clearComparison() }
                                }) {
                                    // Текст кнопки в зависимости от режима
                                    Text(isSelectionMode ? "Done" : "Select")
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor(.accentColor)
                                        .padding(.trailing, 10) // <-- УВЕЛИЧЕННЫЙ ОТСТУП ДЛЯ КНОПКИ
                                }
                            }
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
            .preferredColorScheme(.dark)

            // Плавающая кнопка сравнения (видна только при выборе 2+ объективов)
            if isSelectionMode, dataManager.comparisonSet.count > 1 {
                VStack {
                    Spacer()
                    // Кнопка запуска сравнения выбранных объективов
                    Button(action: {
                        showComparisonSheet = true
                    }) {
                        Text("Compare (\(dataManager.comparisonSet.count)) Lenses")
                            .font(.headline.weight(.heavy))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.5), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                // Анимация появления/скрытия кнопки
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        // Анимации изменения состояния
        .animation(.easeInOut, value: isSelectionMode)
        .animation(.easeInOut, value: dataManager.comparisonSet.count > 1)
        .sheet(isPresented: $showComparisonSheet, onDismiss: {
            // Очистка после закрытия экрана сравнения
            dataManager.clearComparison()
            isSelectionMode = false
        }) {
            // Модальное окно с экраном сравнения объективов
            ComparisonView().environmentObject(dataManager)
        }
    }
}

// Компонент строки объектива в списке избранного
struct LensRow: View {
    // Данные объектива для отображения
    let lens: Lens
    // Флаг режима выбора для сравнения
    let isSelectionMode: Bool
    // Статус выбора объектива для сравнения
    let isSelectedForComparison: Bool

    // Содержимое строки
    var body: some View {
        HStack(spacing: 15) {
            // Индикатор выбора (отображается только в режиме сравнения)
            if isSelectionMode {
                Image(systemName: isSelectedForComparison ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelectedForComparison ? .blue : .secondary)
            }

            // Основная информация об объективе
            VStack(alignment: .leading, spacing: 4) {
                // Название объектива
                Text(lens.display_name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                // Дополнительная информация: производитель и формат
                Text("\(lens.manufacturer) • \(lens.format)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Стрелка навигации (скрыта в режиме выбора)
            if !isSelectionMode {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(
            // Многослойный фон с адаптивным стилем
            ZStack {
                // Базовая подложка с изменяемой прозрачностью
                Color.white.opacity(isSelectedForComparison ? 0.15 : 0.05)
                // Цветная обводка для выбранных объективов
                if isSelectedForComparison {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
        )
        .cornerRadius(16)
        // Плавная анимация изменений состояния
        .animation(.easeInOut(duration: 0.2), value: [isSelectionMode, isSelectedForComparison])
    }
}
