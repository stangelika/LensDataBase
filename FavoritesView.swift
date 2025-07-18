import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLens: Lens? = nil
    @State private var isSelectionMode = false
    @State private var showComparisonSheet = false

    var body: some View {
        // Главный ZStack для размещения плавающей кнопки поверх всего
        ZStack {
            NavigationView {
                ZStack {
                    // Фон
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.sRGB, red: 24 / 255, green: 27 / 255, blue: 37 / 255, opacity: 1),
                            Color(.sRGB, red: 34 / 255, green: 37 / 255, blue: 57 / 255, opacity: 1),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom)
                        .ignoresSafeArea()

                    // Main content
                    VStack(spacing: 20) {
                        // Custom header
                        HStack {
                            Text("Favorites")
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(
                                    colors: [.white, .yellow.opacity(0.85), .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing))
                                .shadow(color: .yellow.opacity(0.18), radius: 12, x: 0, y: 6)
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 22)

                        // Check for empty favorites list
                        if dataManager.favoriteLensesList.isEmpty {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "star.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.yellow.opacity(0.6))
                                Text("No Favorites Yet")
                                    .font(.title2.weight(.bold))
                                Text("Tap the star on a lens's detail page to add it to your favorites.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            Spacer()
                            Spacer()
                        } else {
                            // List
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(dataManager.favoriteLensesList) { lens in
                                        Button(action: {
                                            if isSelectionMode {
                                                dataManager.toggleComparison(lens: lens)
                                            } else {
                                                selectedLens = lens
                                            }
                                        }) {
                                            LensRow(
                                                lens: lens,
                                                isSelectionMode: isSelectionMode,
                                                isSelectedForComparison: dataManager.isInComparison(lens: lens))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 100) // Bottom padding for floating button
                            }
                        }
                    }
                    .sheet(item: $selectedLens) { lens in
                        LensDetailView(lens: lens).environmentObject(dataManager)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !dataManager.favoriteLensesList.isEmpty {
                                Button(action: {
                                    withAnimation { isSelectionMode.toggle() }
                                    if !isSelectionMode { dataManager.clearComparison() }
                                }) {
                                    Text(isSelectionMode ? "Done" : "Select")
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor(.accentColor)
                                        .padding(.trailing, 10) // Increased padding for button
                                }
                            }
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
            .preferredColorScheme(.dark)

            // Плавающая кнопка "Сравнить"
            if isSelectionMode, dataManager.comparisonSet.count > 1 {
                VStack {
                    Spacer()
                    Button(action: {
                        showComparisonSheet = true
                    }) {
                        Text("Compare (\(dataManager.comparisonSet.count)) Lenses")
                            .font(.headline.weight(.heavy))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.5), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: isSelectionMode)
        .animation(.easeInOut, value: dataManager.comparisonSet.count > 1)
        .sheet(isPresented: $showComparisonSheet, onDismiss: {
            dataManager.clearComparison()
            isSelectionMode = false
        }) {
            ComparisonView().environmentObject(dataManager)
        }
    }
}

// Строка списка
struct LensRow: View {
    let lens: Lens
    let isSelectionMode: Bool
    let isSelectedForComparison: Bool

    var body: some View {
        HStack(spacing: 15) {
            if isSelectionMode {
                Image(systemName: isSelectedForComparison ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelectedForComparison ? .blue : .secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lens.displayName)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                Text("\(lens.manufacturer) • \(lens.format)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            if !isSelectionMode {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(
            ZStack {
                Color.white.opacity(isSelectedForComparison ? 0.15 : 0.05)
                if isSelectedForComparison {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: 2)
                }
            })
        .cornerRadius(16)
        .animation(.easeInOut(duration: 0.2), value: [isSelectionMode, isSelectedForComparison])
    }
}
