import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, white: 0.09, opacity: 1),
                    Color(.sRGB, white: 0.15, opacity: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $dataManager.activeTab) {
                // Tab 1: All Lenses
                AllLensesView()
                    .tag(ActiveTab.allLenses)
                
                // Tab 2: Rentals
                RentalView()
                    .tag(ActiveTab.rentalView)
                    
                // Tab 3: Favorites
                FavoritesView()
                    .tag(ActiveTab.favorites)
                
                // Tab 4: Settings and Updates
                UpdateView()
                    .tag(ActiveTab.updateView)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .preferredColorScheme(.dark)
        .onAppear {
            configureTabBar()
            loadDataIfNeeded()
        }
    }
    
    // MARK: - Private Methods
    
    private func configureTabBar() {
        UITabBar.appearance().isHidden = true
    }
    
    private func loadDataIfNeeded() {
        if dataManager.appData == nil {
            dataManager.loadData()
        }
    }
}