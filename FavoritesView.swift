// FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLens: Lens? = nil

    // Вычисляемое свойство для получения только избранных объективов
    private var favoriteLenses: [Lens] {
        // Мы используем .sorted(), чтобы список всегда был в одном порядке
        dataManager.availableLenses
            .filter { dataManager.isFavorite(lens: $0) }
            .sorted { $0.display_name < $1.display_name }
    }

    var body: some View {
        ZStack {
            // Фон как в других разделах
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                    Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Заголовок
                HStack {
                    Text("Favorites")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow.opacity(0.85), .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .yellow.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 22)

                // Проверяем, есть ли что-то в избранном
                if favoriteLenses.isEmpty {
                    // Заглушка, если пусто
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "star.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow.opacity(0.6))
                        Text("No Favorites Yet")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        Text("Tap the star on a lens's detail page to add it to your favorites.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                    Spacer()
                } else {
                    // Список избранных объективов
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favoriteLenses) { lens in
                                Button(action: {
                                    self.selectedLens = lens
                                }) {
                                    LensRow(lens: lens) // Используем простой вид для строки
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            // Открывает детальный вид при выборе объектива
            .sheet(item: $selectedLens) { lens in
                LensDetailView(lens: lens)
                    .environmentObject(dataManager)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Простой вид для отображения строки в списке
// Можете добавить этот struct в конец файла FavoritesView.swift
struct LensRow: View {
    let lens: Lens
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lens.display_name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                Text("\(lens.manufacturer) • \(lens.format)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.callout.weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(16)
    }
}