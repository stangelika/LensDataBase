import SwiftUI

// Экран отображения объективов конкретной компании проката
struct RentalView: View {
    // Менеджер данных для доступа к компаниям проката и объективам
    @EnvironmentObject var dataManager: DataManager
    // Фильтр по формату съемки
    @State private var selectedFormat: String = ""
    // Выбранный объектив для детального просмотра
    @State private var selectedLens: Lens? = nil

    // Вычисляемое свойство: название выбранной компании проката
    var selectedRentalName: String {
        dataManager.appData?.rentals.first(where: { $0.id == dataManager.selectedRentalId })?.name ?? "Rentals"
    }

    // Основное содержимое экрана
    var body: some View {
        ZStack {
            // Градиентный фон в сине-фиолетовых тонах
            AppTheme.Colors.detailViewGradient
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.xxl) {
                // Заголовок с названием выбранной компании проката
                HStack {
                    Text(selectedRentalName)
                        .font(.appLargeTitle)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.primaryText, AppTheme.Colors.blue, AppTheme.Colors.indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: AppTheme.Colors.blue.opacity(0.15), radius: 10, x: 0, y: 4)
                        .animation(.easeInOut(duration: 0.25), value: selectedRentalName)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                // Панель фильтров для выбора компании и формата
                HStack(spacing: 16) {
                    // Выпадающее меню выбора компании проката
                    Menu {
                        Picker("Rental", selection: $dataManager.selectedRentalId) {
                            Text("Choose rental").tag("")
                            // Список всех доступных компаний проката
                            ForEach(dataManager.appData?.rentals ?? []) { rental in
                                Text(rental.name).tag(rental.id)
                            }
                        }
                    } label: {
                        // Кнопка селектора компании с визуальной индикацией
                        GlassFilterChip(
                            icon: "building.2",
                            title: dataManager.selectedRentalId.isEmpty ? "Choose rental" : (dataManager.appData?.rentals.first { $0.id == dataManager.selectedRentalId }?.name ?? "Rental"),
                            accentColor: dataManager.selectedRentalId.isEmpty ? AppTheme.Colors.blue : AppTheme.Colors.green,
                            isActive: !dataManager.selectedRentalId.isEmpty
                        )
                    }
                    
                    // Выпадающее меню выбора формата съемки
                    Menu {
                        Picker("Format", selection: $selectedFormat) {
                            Text("All Formats").tag("")
                            // Динамический список доступных форматов
                            ForEach(Array(Set(dataManager.availableLenses.map(\.format))).sorted(), id: \.self) { format in
                                Text(format).tag(format)
                            }
                        }
                    } label: {
                        // Кнопка селектора формата с визуальной индикацией
                        GlassFilterChip(
                            icon: "crop",
                            title: selectedFormat.isEmpty ? "All Formats" : selectedFormat,
                            accentColor: selectedFormat.isEmpty ? AppTheme.Colors.blue : AppTheme.Colors.green,
                            isActive: !selectedFormat.isEmpty
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.padding24)

                // Основная область контента с условным отображением
                if dataManager.loadingState == .loading {
                    // Индикатор загрузки данных
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.blue))
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .foregroundColor(AppTheme.Colors.quaternaryText)
                            .font(.appBody)
                            .padding(.top, AppTheme.Spacing.sm)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let _ = dataManager.appData, !dataManager.selectedRentalId.isEmpty {
                    // Список объективов выбранной компании проката
                    WeatherStyleLensListView(rentalId: dataManager.selectedRentalId, format: selectedFormat) { lens in
                        // Callback для открытия детального экрана объектива
                        selectedLens = lens
                    }
                } else {
                    // Сообщение-подсказка при отсутствии выбранной компании
                    VStack {
                        Image(systemName: "building.2")
                            .font(.system(size: 54))
                            .foregroundColor(AppTheme.Colors.blue.opacity(0.4))
                            .padding(.bottom, AppTheme.Spacing.md)
                        Text("Choose rental to see lenses")
                            .font(.appHeadline)
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .sheet(item: $selectedLens) { lens in
                // Модальное окно с детальной информацией об объективе
                LensDetailView(lens: lens)
                    .environmentObject(dataManager)
            }
        }
        // Принудительная темная тема
        .preferredColorScheme(.dark)
    }
}
