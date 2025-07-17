// MainTabView_Version3_Version4.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.sRGB, white: 0.09, opacity: 1), Color(.sRGB, white: 0.15, opacity: 1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $dataManager.activeTab) {
                // Экран 1: Все объективы
                AllLensesView()
                    .tag(ActiveTab.allLenses)
                
                // Экран 2: Ренталы
                RentalView()
                    .tag(ActiveTab.rentalView)
                    
                // Экран 3: Избранное
                FavoritesView()
                    .tag(ActiveTab.favorites)
                
                // ЭКРАН 4: ПРОЕКТЫ (НОВЫЙ)
                ProjectsListView()
                    .tag(ActiveTab.projects) // <--- ДОБАВЬ ЭТОТ БЛОК
                
                // Экран 5: Настройки и обновление
                UpdateView()
                    .tag(ActiveTab.updateView)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            // .indexViewStyle(.page(backgroundDisplayMode: .always)) // Раскомментируй для видимых точек
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if dataManager.appData == nil {
                dataManager.loadData()
            }
            UITabBar.appearance().isHidden = true
        }
    }
}