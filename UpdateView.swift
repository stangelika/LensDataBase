// UpdateView.swift

import SwiftUI

struct UpdateView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            // Фон как в других разделах
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 24 / 255, green: 27 / 255, blue: 37 / 255, opacity: 1),
                    Color(.sRGB, red: 34 / 255, green: 37 / 255, blue: 57 / 255, opacity: 1),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                // Заголовок
                HStack {
                    Text("Settings")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .green.opacity(0.85), .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .green.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 22)

                // Карточка с описанием
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Data Synchronization")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Text("The application uses a local database of lenses and cameras for quick access. Press the button below to update the data from the server. This may take some time.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                }
                .padding()
                .background(GlassBackground())
                .padding(.horizontal)

                // Кнопка обновления
                Button(action: {
                    // Вызываем функцию обновления из DataManager
                    dataManager.refreshDataFromAPI()
                }) {
                    HStack {
                        // Показываем индикатор загрузки или иконку
                        if dataManager.loadingState == .loading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.headline)
                        }
                        Text("Update from Server")
                            .font(.headline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: .green.opacity(0.4), radius: 10, y: 5)
                }
                .padding(.horizontal)
                .disabled(dataManager.loadingState == .loading) // Блокируем кнопку во время загрузки

                // Показываем сообщение об ошибке, если она есть
                if case let .error(error) = dataManager.loadingState {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
        }
    }
}
