import SwiftUI

@main
struct LensApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(dataManager)
                .onAppear {
                    // Настройка навигации
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
                    
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    
                    // Настройка общего вида
                    UITableView.appearance().backgroundColor = .clear
                    
                    // Загрузка данных при запуске
                    dataManager.loadData()
                }
        }
    }
}
