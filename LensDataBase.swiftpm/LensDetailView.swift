import SwiftUI

struct LensDetailView: View, Identifiable {
    let id = UUID()
    let lens: Lens
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showCompatibilityCheck = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header with back button
                HStack {
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
                
                // Lens title
                StickyHeader(title: lens.display_name)
                
                // НОВЫЙ БЛОК ДЛЯ ЗАГОЛОВКА И КНОПКИ
                HStack(alignment: .top) {
                    // Название объектива
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(lens.manufacturer) · \(lens.lens_name)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer() // Занимает все свободное место
                    
                    // Кнопка "Избранное"
                    Button(action: {
                        // Вызываем нашу функцию из DataManager
                        dataManager.toggleFavorite(lens: lens)
                    }) {
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
                
                
                // Specifications grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 18), GridItem(.flexible())], spacing: 18) {
                    
                    // --- КАРТОЧКИ С ХАРАКТЕРИСТИКАМИ ---
                    
                    SpecCard(
                        title: "Фокусное расстояние",
                        value: lens.focal_length,
                        icon: "arrow.left.and.right",
                        color: .blue
                    )
                    SpecCard(
                        title: "Диафрагма",
                        value: lens.aperture,
                        icon: "camera.aperture",
                        color: .purple
                    )
                    SpecCard(
                        title: "Формат",
                        value: lens.format,
                        icon: "crop",
                        color: .green
                    )
                    SpecCard(
                        title: "Мин. дистанция",
                        value: lens.close_focus_cm.isEmpty ? lens.close_focus_in : lens.close_focus_cm,
                        icon: "ruler",
                        color: .orange
                    )
                    SpecCard(
                        title: "Круг изображения",
                        value: lens.image_circle,
                        icon: "circle.dashed",
                        color: .teal
                    )
                    if let squeeze = lens.squeeze_factor, squeeze != "N/A" {
                        SpecCard(
                            title: "Коэф. сжатия",
                            value: squeeze,
                            icon: "aspectratio",
                            color: .pink
                        )
                    }
                    SpecCard(
                        title: "Длина",
                        value: lens.length,
                        icon: "arrow.up.and.down",
                        color: .indigo
                    )
                    SpecCard(
                        title: "Передний диаметр",
                        value: lens.front_diameter,
                        icon: "circle",
                        color: .brown
                    )

                    // --- КАРТОЧКИ-КНОПКИ ---
                    
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
                
                // Rentals section
                let rentals = dataManager.rentalsForLens(lens.id)
                if !rentals.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Доступно в аренду")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 4)
                        
                        ForEach(rentals) { rental in
                            Button(action: {
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
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 27/255, green: 29/255, blue: 48/255, opacity: 1),
                    Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255, opacity: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCompatibilityCheck) {
            CameraLensVisualizerRoot(lens: lens)
        }
    }
}

// ... остальной код файла (SpecCard, RentalCard и т.д.) без изменений ...
// --- ОСТАЛЬНЫЕ КОМПОНЕНТЫ ---

// Закрепленный заголовок
struct StickyHeader: View {
    let title: String
    var body: some View {
        HStack {
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

// Карточка характеристики
struct SpecCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(color.opacity(0.15))
                    )
                
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Карточка рентала
struct RentalCard: View {
    let rental: Rental
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text(rental.name)
                    .font(.headline.weight(.semibold))
                Spacer()
                Image(systemName: "building.2")
                    .foregroundColor(.secondary)
            }
            Text(rental.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Divider()
                .padding(.vertical, 4)
            HStack(spacing: 16) {
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Кнопка контакта в карточке рентала
struct ContactButton: View {
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .imageScale(.small)
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .foregroundColor(color)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.16))
            )
        }
    }
}