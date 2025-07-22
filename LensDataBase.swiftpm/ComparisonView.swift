import SwiftUI

struct ComparisonView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    private var lensesToCompare: [Lens] {
        dataManager.comparisonSet.compactMap { lensId in
            dataManager.availableLenses.first { $0.id == lensId }
        }
        .sorted { $0.display_name < $1.display_name }
    }
    
    private let specsToShow: [(title: String, key: KeyPath<Lens, String>, icon: String, color: Color)] = [
        ("Фокусное расстояние", \.focal_length, "arrow.left.and.right", AppTheme.Colors.blue),
        ("Диафрагма", \.aperture, "camera.aperture", AppTheme.Colors.purple),
        ("Мин. дистанция", \.close_focus_cm, "ruler", AppTheme.Colors.orange)
    ]
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.padding18),
        GridItem(.flexible(), spacing: AppTheme.Spacing.padding18)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Comparison")
                        .font(.appLargeTitle)
                        .gradientText(AppTheme.Colors.favoriteTitleGradient)
                        .shadow(color: AppTheme.Colors.yellow.opacity(0.2), radius: 10, x: 0, y: 4)
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Закрыть")
                                .font(.appBodyMedium.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)
                .padding(.bottom, AppTheme.Spacing.xl)
                
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: AppTheme.Spacing.xxl) {
                        ForEach(lensesToCompare) { lens in
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.padding18) {
                                Text(lens.lens_name)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .padding(.leading, AppTheme.Spacing.sm)
                                
                                ForEach(specsToShow, id: \.title) { spec in
                                    SpecCard(
                                        title: spec.title,
                                        value: lens[keyPath: spec.key],
                                        icon: spec.icon,
                                        color: spec.color
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}
