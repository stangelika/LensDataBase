import SwiftUI

struct LensDetailView: View, Identifiable {
    let id = UUID() // Note: for stable IDs in ForEach or NavigationLink, consider using lens.id
    let lens: Lens
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss // Using @Environment(\.dismiss) for iOS 15+
    @State private var showCompatibilityCheck = false
    @State private var showingProjectSelection = false // State for showing project selection sheet
    
    var body: some View {
        // Wrap everything in VStack to place button below ScrollView
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    // Header with back button
                    HStack {
                        Button(action: {
                            dismiss() // Using dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(DesignSystem.Spacing.sm)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.contentInsets)
                    .padding(.top, DesignSystem.Spacing.sm)
                    
                    // Lens title
                    StickyHeader(title: lens.display_name)
                    
                    // Header block with title and buttons
                    HStack(alignment: .top) {
                        // Lens name
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("\(lens.manufacturer) · \(lens.lens_name)")
                                .font(DesignSystem.Typography.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer() // Takes all available space
                        
                        // Favorite button
                        Button(action: {
                            dataManager.toggleFavorite(lens: lens)
                        }) {
                            Image(systemName: dataManager.isFavorite(lens: lens) ? "star.fill" : "star")
                                .font(.title2.weight(.bold))
                                .foregroundColor(dataManager.isFavorite(lens: lens) ? .yellow : .gray)
                                .padding(DesignSystem.Spacing.sm)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: .yellow.opacity(dataManager.isFavorite(lens: lens) ? 0.3 : 0), radius: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dataManager.isFavorite(lens: lens))
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.contentInsets)
                    
                    // Specifications grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: DesignSystem.Spacing.lg), GridItem(.flexible())], spacing: DesignSystem.Spacing.lg) {
                        
                        // Specification cards
                        
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
                    .padding(.horizontal, DesignSystem.Spacing.contentInsets)

                    // Rentals section
                    let rentals = dataManager.rentalsForLens(lens.id)
                    if !rentals.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                            Text("Доступно в аренду")
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(.white)
                                .padding(.leading, DesignSystem.Spacing.xs)
                            
                            ForEach(rentals) { rental in
                                Button(action: {
                                    dataManager.selectedRentalId = rental.id
                                    dataManager.activeTab = .rentalView
                                    dismiss() // Используем dismiss()
                                }) {
                                    RentalCard(rental: rental)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, DesignSystem.Spacing.xl)
                        .padding(.horizontal, DesignSystem.Spacing.contentInsets)
                    }
                }
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
            
            // --- ОБНОВЛЕННАЯ И ЗАКРЕПЛЕННАЯ КНОПКА ---
            Button(action: {
                showingProjectSelection = true
            }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "folder.fill.badge.plus")
                        .font(.title3.weight(.semibold))
                    Text("Add to Project")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(.white)
                .padding(DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(DesignSystem.Gradients.buttonPrimary)
                .cornerRadius(DesignSystem.CornerRadius.lg)
                .designSystemShadow(DesignSystem.Shadows.primaryGlow)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.contentInsets)
            .padding(.bottom, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .background(
            DesignSystem.Gradients.detailBackground
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCompatibilityCheck) {
            CameraLensVisualizerRoot(lens: lens)
        }
        .sheet(isPresented: $showingProjectSelection) {
            // ВАШ КОД ДЛЯ ProjectSelectionView. Замените lensIDToAdd на lens, если нужно передать весь объект
            ProjectSelectionView(lensIDToAdd: lens.id)
                .environmentObject(dataManager)
        }
    }
}

// --- ОСТАЛЬНЫЕ КОМПОНЕНТЫ (без изменений) ---

// Закрепленный заголовок
struct StickyHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.largeTitle)
                .foregroundStyle(DesignSystem.Gradients.textPrimary)
                .designSystemShadow(DesignSystem.Shadows.sm)
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .padding(.horizontal, DesignSystem.Spacing.contentInsets)
    }
}

// Карточка характеристики
struct SpecCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(color.opacity(0.15))
                    )
                
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.leading, DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .cardStyle()
    }
}

// Карточка рентала
struct RentalCard: View {
    let rental: Rental
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text(rental.name)
                    .font(DesignSystem.Typography.headline)
                Spacer()
                Image(systemName: "building.2")
                    .foregroundColor(.secondary)
            }
            Text(rental.address)
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondary)
            Divider()
                .padding(.vertical, DesignSystem.Spacing.xs)
            HStack(spacing: DesignSystem.Spacing.lg) {
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
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
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
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .imageScale(.small)
                Text(label)
                    .font(DesignSystem.Typography.caption)
                    .lineLimit(1)
            }
            .foregroundColor(color)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.16))
            )
        }
    }
}