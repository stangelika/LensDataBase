import SwiftUI

@main
struct LensApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(dataManager)
                .onAppear {
                    setupAppearance()
                    dataManager.loadData()
                }
        }
    }
    
    /// Configures the app's UI appearance
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure general view appearance
        UITableView.appearance().backgroundColor = .clear
    }
}
