import SwiftUI

// Детальный экран объектива с полной технической информацией
struct LensDetailView: View, Identifiable {
    let id = UUID()
    // Объектив для отображения детальной информации
    let lens: Lens
    // Менеджер данных для управления избранным и сравнением
    @EnvironmentObject var dataManager: DataManager
    // Доступ к методу закрытия модального окна
    @Environment(\.presentationMode) var presentationMode
    // Состояние отображения проверки совместимости с камерами
    @State private var showCompatibilityCheck = false

    // Основное содержимое экрана
    var body: some View {
        // Скроллируемый контейнер для всего контента
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Заголовочная область с кнопкой возврата
                HStack {
                    // Кнопка закрытия детального экрана
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Компонент липкого заголовка с названием объектива
                StickyHeader(title: lens.display_name)

                // Блок с основной информацией и кнопками действий
                HStack(alignment: .top) {
                    // Информация о производителе и модели
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(lens.manufacturer) · \(lens.lens_name)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    Spacer() // Занимает все свободное место

                    // Кнопка добавления/удаления из избранного
                    Button(action: {
                        // Переключение статуса избранного через DataManager
                        dataManager.toggleFavorite(lens: lens)
                    }) {
                        // Иконка звезды с адаптивным состоянием
                        Image(systemName: dataManager.isFavorite(lens: lens) ? "star.fill" : "star")
                            .font(.title2.weight(.bold))
                            .foregroundColor(dataManager.isFavorite(lens: lens) ? .yellow : .gray)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .yellow.opacity(dataManager.isFavorite(lens: lens) ? 0.3 : 0), radius: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dataManager.isFavorite(lens: lens))
                    }
                }
                .padding(.bottom, 8)
                .padding(.horizontal)

                // Сетка технических характеристик объектива
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible())], spacing: 18) {
                    // Карточки с основными техническими параметрами

                    // Фокусное расстояние
                    SpecCard(
                        title: "Фокусное расстояние",
                        value: lens.focal_length,
                        icon: "arrow.left.and.right",
                        color: .blue
                    )
                    // Максимальная диафрагма
                    SpecCard(
                        title: "Диафрагма",
                        value: lens.aperture,
                        icon: "camera.aperture",
                        color: .purple
                    )
                    // Формат съемки
                    SpecCard(
                        title: "Формат",
                        value: lens.format,
                        icon: "crop",
                        color: .green
                    )
                    // Минимальная дистанция фокусировки
                    SpecCard(
                        title: "Мин. дистанция",
                        value: lens.close_focus_cm.isEmpty ? lens.close_focus_in : lens.close_focus_cm,
                        icon: "ruler",
                        color: .orange
                    )
                    // Диаметр круга изображения
                    SpecCard(
                        title: "Круг изображения",
                        value: lens.image_circle,
                        icon: "circle.dashed",
                        color: .teal
                    )
                    // Коэффициент сжатия для анаморфных объективов (если применимо)
                    if let squeeze = lens.squeeze_factor, squeeze != "N/A" {
                        SpecCard(
                            title: "Коэф. сжатия",
                            value: squeeze,
                            icon: "aspectratio",
                            color: .pink
                        )
                    }
                    // Длина объектива
                    SpecCard(
                        title: "Длина",
                        value: lens.length,
                        icon: "arrow.up.and.down",
                        color: .indigo
                    )
                    // Диаметр передней линзы
                    SpecCard(
                        title: "Передний диаметр",
                        value: lens.front_diameter,
                        icon: "circle",
                        color: .brown
                    )

                    // Интерактивные карточки с действиями

                    // Кнопка поиска изображений объектива в Google
                    Button(action: {
                        let query = lens.display_name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? lens.display_name
                        if let url = URL(string: "https://www.google.com/search?tbm=isch&q=\(query)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        SpecCard(
                            title: "Действие",
                            value: "Поиск Google",
                            icon: "photo.on.rectangle.angled",
                            color: .blue
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Кнопка открытия проверки совместимости с камерами
                    Button(action: {
                        showCompatibilityCheck = true
                    }) {
                        SpecCard(
                            title: "Действие",
                            value: "Проверить совм.",
                            icon: "camera.metering.center.weighted",
                            color: .green
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)

                // Секция компаний проката, где доступен данный объектив
                let rentals = dataManager.rentalsForLens(lens.id)
                if !rentals.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        // Заголовок секции проката
                        Text("Доступно в аренду")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 4)

                        // Список компаний проката с переходами
                        ForEach(rentals) { rental in
                            Button(action: {
                                // Переход к экрану конкретной компании проката
                                dataManager.selectedRentalId = rental.id
                                dataManager.activeTab = .rentalView
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                RentalCard(rental: rental)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .background(
            // Фоновый градиент для всего экрана
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 27 / 255, green: 29 / 255, blue: 48 / 255, opacity: 1),
                    Color(.sRGB, red: 38 / 255, green: 36 / 255, blue: 97 / 255, opacity: 1),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCompatibilityCheck) {
            // Полноэкранное модальное окно с визуализацией совместимости камер
            CameraLensVisualizerRoot(lens: lens)
        }
    }
}

// MARK: - Вспомогательные компоненты

// Компонент закрепленного заголовка с градиентным стилем
struct StickyHeader: View {
    // Текст заголовка
    let title: String
    
    // Содержимое заголовка
    var body: some View {
        HStack {
            // Название объектива с градиентным эффектом
            Text(title)
                .font(.system(size: 33, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.10), radius: 6, x: 0, y: 2)
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal)
    }
}

// Карточка отображения технической характеристики
struct SpecCard: View {
    // Название характеристики
    let title: String
    // Значение характеристики
    let value: String
    // Иконка для визуализации
    let icon: String
    // Цвет акцента карточки
    let color: Color

    // Содержимое карточки
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            // Заголовочная область с иконкой
            HStack(alignment: .center) {
                // Иконка характеристики с цветной подложкой
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(color.opacity(0.15))
                    )

                // Название характеристики
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            // Значение характеристики
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.leading, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(
            // Полупрозрачная подложка карточки
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            // Тонкая обводка карточки
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Карточка компании проката с контактной информацией
struct RentalCard: View {
    // Данные компании проката
    let rental: Rental

    // Содержимое карточки
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            // Заголовочная область с названием компании
            HStack {
                // Название компании проката
                Text(rental.name)
                    .font(.headline.weight(.semibold))
                Spacer()
                // Иконка здания для визуального акцента
                Image(systemName: "building.2")
                    .foregroundColor(.secondary)
            }
            // Адрес компании
            Text(rental.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            // Разделительная линия перед контактами
            Divider()
                .padding(.vertical, 4)
            // Кнопки связи с компанией
            HStack(spacing: 16) {
                // Кнопка звонка по телефону
                ContactButton(
                    label: rental.phone,
                    icon: "phone",
                    color: .green,
                    action: {
                        if let url = URL(string: "tel://\(rental.phone.filter("0123456789+".contains))") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                // Кнопка перехода на веб-сайт
                ContactButton(
                    label: "Website",
                    icon: "globe",
                    color: .blue,
                    action: {
                        if let url = URL(string: rental.website) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            // Полупрозрачная подложка карточки
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            // Тонкая обводка карточки
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Кнопка контакта с компанией проката
struct ContactButton: View {
    // Текст кнопки
    let label: String
    // Иконка кнопки
    let icon: String
    // Цвет кнопки
    let color: Color
    // Действие при нажатии
    let action: () -> Void

    // Содержимое кнопки
    var body: some View {
        Button(action: action) {
            // Горизонтальная компоновка иконки и текста
            HStack(spacing: 6) {
                // Иконка действия
                Image(systemName: icon)
                    .imageScale(.small)
                // Текст кнопки
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .foregroundColor(color)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                // Цветная капсульная подложка
                Capsule(style: .continuous)
                    .fill(color.opacity(0.16))
            )
        }
    }
}
