// UpdateView.swift

import SwiftUI

// Экран настроек и обновления данных приложения
struct UpdateView: View {
    // Менеджер данных для управления состоянием и загрузкой данных
    @EnvironmentObject var dataManager: DataManager

    // Основное содержимое экрана
    var body: some View {
        ZStack {
            // Темный градиентный фон в стиле других экранов
            AppTheme.Colors.primaryGradient
                .ignoresSafeArea()

            VStack(spacing: 25) {
                // Заголовок экрана настроек
                HStack {
                    Text("Settings")
                        .font(.appLargeTitle)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.primaryText, AppTheme.Colors.green.opacity(0.85), AppTheme.Colors.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppTheme.Colors.green.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                // Информационная карточка о синхронизации данных
                VStack(alignment: .leading, spacing: 12) {
                    // Заголовок секции с иконкой
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.green)
                        Text("Data Synchronization")
                            .font(.appHeadline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                    // Описание функциональности синхронизации
                    Text("The application uses a local database of lenses and cameras for quick access. Press the button below to update the data from the server. This may take some time.")
                        .font(.appBody)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .lineSpacing(AppTheme.Spacing.sm)
                }
                .padding()
                .background(GlassBackground())
                .padding(.horizontal)

                // Кнопка инициации обновления данных с сервера
                Button(action: {
                    // Запуск процесса обновления через DataManager
                    dataManager.refreshDataFromAPI()
                }) {
                    HStack {
                        // Адаптивная иконка: индикатор загрузки или стрелка обновления
                        if dataManager.loadingState == .loading {
                            ProgressView()
                                .tint(AppTheme.Colors.primaryText)
                        } else {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.appHeadline)
                        }
                        Text("Update from Server")
                            .font(.appHeadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .background(AppTheme.Colors.green.opacity(0.8))
                    .cornerRadius(AppTheme.CornerRadius.medium)
                    .shadow(color: AppTheme.Colors.green.opacity(0.4), radius: 10, y: 5)
                }
                .padding(.horizontal)
                // Блокировка кнопки во время активной загрузки
                .disabled(dataManager.loadingState == .loading)

                // Условное отображение сообщения об ошибке
                if case let .error(error) = dataManager.loadingState {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
        }
        // Принудительная темная тема
        .preferredColorScheme(.dark)
    }
}
