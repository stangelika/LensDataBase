import SwiftUI

@main
struct LensApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(dataManager)
                .onAppear {
                    // Navigation bar configuration
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
                    
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    
                    // General appearance setup
                    UITableView.appearance().backgroundColor = .clear
                    
                    // Load data on startup
                    dataManager.loadData()
                }
        }
    }
}
