// CameraSelectionView.swift

import SwiftUI

struct CameraSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @Binding var project: Project // Принимаем Binding для прямого изменения

    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                        Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Text("Select a Camera")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    if dataManager.cameras.isEmpty {
                        Spacer()
                        Text("No cameras available.")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    } else {
                        List {
                            ForEach(dataManager.cameras) { camera in
                                Button(action: {
                                    // Добавляем или удаляем камеру из проекта
                                    toggleCameraInProject(cameraID: camera.id)
                                    // Не закрываем лист, чтобы можно было выбрать несколько камер
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(camera.manufacturer) \(camera.model)")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("Sensor: \(camera.sensor)")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        // Если камера уже в проекте, показываем галочку
                                        if project.cameraIDs.contains(camera.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.green)
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .animation(.easeInOut, value: project.cameraIDs)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss() // Закрываем лист
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.cyan)
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Функция для добавления/удаления ID камеры
    private func toggleCameraInProject(cameraID: String) {
        if project.cameraIDs.contains(cameraID) {
            project.cameraIDs.removeAll { $0 == cameraID }
        } else {
            project.cameraIDs.append(cameraID)
        }
        dataManager.saveProjects() // Сохраняем изменения
    }
}