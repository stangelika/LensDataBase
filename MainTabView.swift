// MainTabView_Version3_Version4.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            // Фон можно оставить общим или убрать, если у каждого экрана свой
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
        
    // Экран 3: Избранное (НОВЫЙ)
    FavoritesView()
        .tag(ActiveTab.favorites) // <--- ДОБАВЬТЕ ЭТОТ БЛОК
    
    // Экран 4: Настройки и обновление
    UpdateView()
        .tag(ActiveTab.updateView)
}
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Этот блок можно оставить, но основная загрузка уже не здесь
            if dataManager.appData == nil {
                dataManager.loadData() // Теперь загружает локальные данные
            }
            UITabBar.appearance().isHidden = true
        }
    }
}