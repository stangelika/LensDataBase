// ProjectsListView.swift

import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject var dataManager: DataManager

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

                VStack(spacing: 20) {
                    // Кастомный заголовок
                    HStack {
                        Text("My Projects")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.white, .cyan.opacity(0.85), .blue], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .cyan.opacity(0.18), radius: 12, x: 0, y: 6)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 22)

                    // Проверка на пустой список
                    if dataManager.projects.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "film.stack")
                                .font(.system(size: 60))
                                .foregroundColor(.cyan.opacity(0.6))
                            Text("No Projects Created")
                                .font(.title2.weight(.bold))
                            Text("Tap the '+' button to create a new project and plan your shoot.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        // Список проектов
                        List {
                            ForEach(dataManager.projects) { project in
                                // Пока что навигация никуда не ведет, мы это сделаем в след. шаге
                                NavigationLink(destination: Text("Detail for \(project.name)")) {
                                    ProjectRow(project: project)
                                }
                            }
                            .onDelete(perform: dataManager.deleteProject)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 4)
                        }
                        .listStyle(.plain)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dataManager.addProject()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                        .padding(.trailing, 10)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

// Вид для строки в списке проектов
struct ProjectRow: View {
    let project: Project
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(project.name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                Text("Lenses: \(project.lensIDs.count) • Cameras: \(project.cameraIDs.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}