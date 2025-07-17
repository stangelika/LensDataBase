import SwiftUI

@main
struct LensApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(dataManager)
                .onAppear {
                    configureAppearance()
                    dataManager.loadData()
                }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureAppearance() {
        // Configure navigation appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure general appearance
        UITableView.appearance().backgroundColor = .clear
    }
}
