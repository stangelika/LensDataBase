// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            DesignSystem.Gradients.primaryBackground
                .ignoresSafeArea()
            
            TabView(selection: $dataManager.activeTab) {
                // Screen 1: All Lenses
                AllLensesView()
                    .tag(ActiveTab.allLenses)
                
                // Screen 2: Rentals
                RentalView()
                    .tag(ActiveTab.rentalView)
                    
                // Screen 3: Favorites
                FavoritesView()
                    .tag(ActiveTab.favorites)
                
                // Screen 4: Projects
                ProjectsListView()
                    .tag(ActiveTab.projects)
                
                // Screen 5: Settings and Updates
                UpdateView()
                    .tag(ActiveTab.updateView)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            // .indexViewStyle(.page(backgroundDisplayMode: .always)) // Uncomment for visible dots
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