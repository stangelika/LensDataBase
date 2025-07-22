import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            AppTheme.Colors.mainTabGradient
                .ignoresSafeArea()
            
            TabView(selection: $dataManager.activeTab) {
                AllLensesView()
                    .tag(ActiveTab.allLenses)
                
                FavoritesView()
                    .tag(ActiveTab.favorites)
                
                RentalAndSettingsView()
                    .tag(ActiveTab.rentalView)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            if dataManager.appData == nil {
                dataManager.loadData()
            }
            UITabBar.appearance().isHidden = true
        }
    }
}
