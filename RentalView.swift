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
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 27 / 255, green: 29 / 255, blue: 48 / 255, opacity: 1),
                    Color(.sRGB, red: 38 / 255, green: 36 / 255, blue: 97 / 255, opacity: 1),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок с названием выбранной компании проката
                HStack {
                    Text(selectedRentalName)
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .blue, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.15), radius: 10, x: 0, y: 4)
                        .animation(.easeInOut(duration: 0.25), value: selectedRentalName)
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 22)

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
                            accentColor: dataManager.selectedRentalId.isEmpty ? .blue : .green,
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
                            accentColor: selectedFormat.isEmpty ? .blue : .green,
                            isActive: !selectedFormat.isEmpty
                        )
                    }
                }
                .padding(.horizontal, 24)

                // Основная область контента с условным отображением
                if dataManager.loadingState == .loading {
                    // Индикатор загрузки данных
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.subheadline)
                            .padding(.top, 4)
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
                            .foregroundColor(.blue.opacity(0.4))
                            .padding(.bottom, 8)
                        Text("Choose rental to see lenses")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
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
