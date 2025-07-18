// MainTabView.swift

import SwiftUI

// Главный экран с вкладками для навигации по приложению
struct MainTabView: View {
    // Менеджер данных для доступа к состоянию приложения
    @EnvironmentObject var dataManager: DataManager

    // Основное содержимое экрана
    var body: some View {
        // Контейнер с фоновым градиентом
        ZStack {
            // Темный градиентный фон для всего экрана
            AppTheme.Colors.mainTabGradient
                .ignoresSafeArea()

            // Основной контейнер вкладок с постраничной навигацией
            TabView(selection: $dataManager.activeTab) {
                // Экран 1: Все объективы в базе данных
                AllLensesView()
                    .tag(ActiveTab.allLenses)

                // Экран 2: Компании проката оборудования
                RentalView()
                    .tag(ActiveTab.rentalView)

                // Экран 3: Избранные объективы пользователя
                FavoritesView()
                    .tag(ActiveTab.favorites)

                
                // Экран 5: Настройки и обновление данных
                UpdateView()
                    .tag(ActiveTab.updateView)
            }
            // Стиль постраничной навигации с автоматическими индикаторами
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            // .indexViewStyle(.page(backgroundDisplayMode: .always)) // Раскомментируй для видимых точек
        }
        // Принудительная темная тема для всего интерфейса
        .preferredColorScheme(.dark)
        .onAppear {
            // Загружаем данные если они еще не были загружены
            if dataManager.appData == nil {
                dataManager.loadData()
            }
            // Скрываем стандартную панель табов (используем кастомную навигацию)
            UITabBar.appearance().isHidden = true
        }
    }
}
