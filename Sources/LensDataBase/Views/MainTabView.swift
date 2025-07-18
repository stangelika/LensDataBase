import Foundation

#if canImport(SwiftUI)
    import SwiftUI


struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, white: 0.09, opacity: 1),
                    Color(.sRGB, white: 0.15, opacity: 1),
                ]),
                startPoint: .top,
                endPoint: .bottom)
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

                // Экран 4: Настройки и обновление
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

#endif
