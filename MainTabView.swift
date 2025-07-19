// MainTabView.swift

import SwiftUI

// Главный экран с вкладками для навигации по приложению
struct MainTabView: View {
    // Менеджер данных для доступа к состоянию приложения
    @EnvironmentObject var dataManager: DataManager

    // Основное содержимое экрана

    var body: some View {
        ZStack {
            // Фон, который будет на весь экран
            AppTheme.Colors.mainTabGradient
                .ignoresSafeArea()

            // TabView со всеми экранами
            TabView(selection: $dataManager.activeTab) {
                AllLensesView()
                    .tag(ActiveTab.allLenses)

                RentalView()
                    .tag(ActiveTab.rentalView)

                FavoritesView()
                    .tag(ActiveTab.favorites)

                UpdateView()
                    .tag(ActiveTab.updateView)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .ignoresSafeArea() // <--- ВОТ КЛЮЧЕВОЕ ИЗМЕНЕНИЕ
        .preferredColorScheme(.dark)
        .onAppear {
            if dataManager.appData == nil {
                dataManager.loadData()
            }
            UITabBar.appearance().isHidden = true
        }
    }
}
