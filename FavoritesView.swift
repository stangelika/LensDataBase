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
                    AppTheme.Colors.primaryGradient
                        .ignoresSafeArea()

                    // Основная область контента
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        // Заголовок секции с градиентным стилем
                        HStack {
                            Text("Favorites")
                                .font(.appLargeTitle)
                                .gradientText(AppTheme.Colors.favoriteTitleGradient)
                                .shadow(color: AppTheme.Colors.yellow.opacity(0.18), radius: 12, x: 0, y: 6)
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.xxxl)
                        .padding(.top, AppTheme.Spacing.padding22)

                        // Условное отображение при отсутствии избранных объективов
                        if dataManager.favoriteLensesList.isEmpty {
                            Spacer()
                            // Сообщение о пустом списке избранного
                            VStack(spacing: AppTheme.Spacing.lg) {
                                Image(systemName: "star.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.Colors.yellow.opacity(0.6))
                                Text("No Favorites Yet")
                                    .font(.title2.weight(.bold))
                                Text("Tap the star on a lens's detail page to add it to your favorites.")
                                    .font(.appBody)
                                    .foregroundColor(AppTheme.Colors.tertiaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                            Spacer()
                        } else {
                            // Скроллируемый список избранных объективов
                            ScrollView {
                                LazyVStack(spacing: AppTheme.Spacing.xl) {
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
                                        .font(.appHeadline)
                                        .foregroundColor(.accentColor)
                                        .padding(.trailing, AppTheme.Spacing.padding10)
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
                            .font(.appHeadline.weight(.heavy))
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.Colors.blue)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .shadow(color: AppTheme.Colors.blue.opacity(0.5), radius: 10, y: 5)
                    }
                    .padding(.horizontal, AppTheme.Spacing.padding24)
                    .padding(.bottom, AppTheme.Spacing.xxl)
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
        HStack(spacing: AppTheme.Spacing.padding15) {
            // Индикатор выбора (отображается только в режиме сравнения)
            if isSelectionMode {
                Image(systemName: isSelectedForComparison ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelectedForComparison ? AppTheme.Colors.blue : AppTheme.Colors.captionText)
            }

            // Основная информация об объективе
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                // Название объектива
                Text(lens.display_name)
                    .font(.appHeadline.weight(.bold))
                    .foregroundColor(AppTheme.Colors.primaryText)
                // Дополнительная информация: производитель и формат
                Text("\(lens.manufacturer) • \(lens.format)")
                    .font(.appBody)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            // Стрелка навигации (скрыта в режиме выбора)
            if !isSelectionMode {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.disabledText)
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
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(AppTheme.Colors.blue, lineWidth: 2)
                }
            }
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        // Плавная анимация изменений состояния
        .animation(.easeInOut(duration: 0.2), value: [isSelectionMode, isSelectedForComparison])
    }
}
