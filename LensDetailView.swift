import SwiftUI

struct LensDetailView: View, Identifiable {
    let id = UUID()

    let lens: Lens

    @EnvironmentObject var dataManager: DataManager

    @Environment(\.presentationMode) var presentationMode

    @State private var showCompatibilityCheck = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxl) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }
                    ) {
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .padding(AppTheme.Spacing.padding10)
                        .background(AppTheme.Colors.toolbarBackground)
                        .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, AppTheme.Spacing.padding10)

                StickyHeader(title: lens.display_name)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.padding10) {
                        Text("\(lens.manufacturer) · \(lens.lens_name)")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.captionText)
                    }
                    Spacer()

                    Button(action: {
                        dataManager.toggleFavorite(lens: lens)
                    }
                    ) {
                        Image(systemName: dataManager.isFavorite(lens: lens) ? "star.fill": "star")
                        .font(.title2.weight(.bold))
                        .foregroundColor(dataManager.isFavorite(lens: lens) ? AppTheme.Colors.yellow: AppTheme.Colors.captionText)
                        .padding(AppTheme.Spacing.md)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.Colors.yellow.opacity(dataManager.isFavorite(lens: lens) ? 0.3: 0), radius: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dataManager.isFavorite(lens: lens))
                    }

                }
                .padding(.bottom, AppTheme.Spacing.md)
                .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.Spacing.padding18), GridItem(.flexible())], spacing: AppTheme.Spacing.padding18) {
                    SpecCard(
                    title: "Фокусное расстояние", value: lens.focal_length, icon: "arrow.left.and.right", color: AppTheme.Colors.blue
                    )

                    SpecCard(
                    title: "Диафрагма", value: lens.aperture, icon: "camera.aperture", color: AppTheme.Colors.purple
                    )

                    SpecCard(
                    title: "Формат", value: lens.format, icon: "crop", color: AppTheme.Colors.green
                    )

                    SpecCard(
                    title: "Мин. дистанция", value: lens.close_focus_cm.isEmpty ? lens.close_focus_in: lens.close_focus_cm, icon: "ruler", color: AppTheme.Colors.orange
                    )

                    SpecCard(
                    title: "Круг изображения", value: lens.image_circle, icon: "circle.dashed", color: AppTheme.Colors.teal
                    )

                    if let squeeze = lens.squeeze_factor, squeeze    != "N / A" {
                        SpecCard(
                        title: "Коэф. сжатия", value: squeeze, icon: "aspectratio", color: AppTheme.Colors.pink
                        )
                    }
                    SpecCard(
                    title: "Длина", value: lens.length, icon: "arrow.up.and.down", color: AppTheme.Colors.indigo
                    )

                    SpecCard(
                    title: "Передний диаметр", value: lens.front_diameter, icon: "circle", color: AppTheme.Colors.brown
                    )

                    Button(action: {
                        let query = lens.display_name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? lens.display_name
                        if let url = URL(string: "https://www.google.com/search?tbm=isch&q=\(query)") {
                            UIApplication.shared.open(url)
                        }

                    }
                    ) {
                        SpecCard(
                        title: "Действие", value: "Поиск Google", icon: "photo.on.rectangle.angled", color: AppTheme.Colors.blue
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showCompatibilityCheck = true
                    }
                    ) {
                        SpecCard(
                        title: "Действие", value: "Проверить совм.", icon: "camera.metering.center.weighted", color: AppTheme.Colors.green
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)

                let rentals = dataManager.rentalsForLens(lens.id)
                if !rentals.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                        Text("Доступно в аренду")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .padding(.leading, AppTheme.Spacing.sm)

                        ForEach(rentals) {
                            rental in
                            Button(action: {
                                dataManager.selectedRentalId = rental.id
                                dataManager.activeTab = .rentalView
                                presentationMode.wrappedValue.dismiss()
                            }
                            ) {
                                RentalCard(rental: rental)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                    }
                    .padding(.top, AppTheme.Spacing.xxl)
                    .padding(.horizontal)
                }

            }
            .padding(.bottom, AppTheme.Spacing.padding30)
        }
        .background(

        AppTheme.Colors.detailViewGradient
        .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCompatibilityCheck) {
            CameraLensVisualizerRoot(lens: lens)
        }

    }

}
struct StickyHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            .font(.appTitle)
            .gradientText(AppTheme.Colors.stickyHeaderGradient)
            .shadow(color: AppTheme.Colors.blue.opacity(0.10), radius: 6, x: 0, y: 2)
            Spacer()
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .padding(.horizontal)
    }

}
struct SpecCard: View {
    let title: String

    let value: String

    let icon: String

    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.padding11) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(
                Circle().fill(color.opacity(0.15))
                )

                Text(title)
                .font(.appCaption)
                .foregroundColor(AppTheme.Colors.captionText)
            }
            Text(value)
            .font(.system(.title3, design: .rounded).weight(.semibold))
            .foregroundColor(AppTheme.Colors.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.leading, AppTheme.Spacing.sm)
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .glassCard(cornerRadius: AppTheme.CornerRadius.xlarge)
    }

}
struct RentalCard: View {
    let rental: Rental

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text(rental.name)
                .font(.appHeadline)
                Spacer()

                Image(systemName: "building.2")
                .foregroundColor(AppTheme.Colors.captionText)
            }
            Text(rental.address)
            .font(.appBody)
            .foregroundColor(AppTheme.Colors.captionText)

            Divider()
            .padding(.vertical, AppTheme.Spacing.sm)

            HStack(spacing: AppTheme.Spacing.xl) {
                ContactButton(
                label: rental.phone, icon: "phone", color: AppTheme.Colors.green, action: {
                    if let url = URL(string: "tel: /  / \(rental.phone.filter("0123456789 + ".contains))") {
                        UIApplication.shared.open(url)
                    }

                }
                )

                ContactButton(
                label: "Website", icon: "globe", color: AppTheme.Colors.blue, action: {
                    if let url = URL(string: rental.website) {
                        UIApplication.shared.open(url)
                    }

                }
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .glassCard(cornerRadius: AppTheme.CornerRadius.xlarge)
    }

}
struct ContactButton: View {
    let label: String

    let icon: String

    let color: Color

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.padding6) {
                Image(systemName: icon)
                .imageScale(.small)

                Text(label)
                .font(.appBody)
                .lineLimit(1)
            }
            .foregroundColor(color)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .background(

            Capsule(style: .continuous)
            .fill(color.opacity(0.16))
            )
        }

    }

}
