import SwiftUI

// Главное приложение LensDataBase для iPad
@main
struct LensApp: App {
    // Центральный менеджер данных для управления состоянием приложения
    @StateObject private var dataManager = DataManager()

    // Основная сцена приложения
    var body: some Scene {
        WindowGroup {
            // Стартовый экран с заставкой
            SplashScreenView()
                .environmentObject(dataManager)
                .onAppear {
                    // Настройка внешнего вида навигационной панели
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance

                    // Настройка прозрачности фона таблиц
                    UITableView.appearance().backgroundColor = .clear

                    // Инициализация загрузки данных о линзах при запуске приложения
                    dataManager.loadData()
                }
        }
    }
}
