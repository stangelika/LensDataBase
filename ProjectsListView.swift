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
                        // Projects list
                        List {
                            ForEach($dataManager.projects) { $project in
                                // NavigationLink leads to ProjectDetailView
                                NavigationLink(destination: ProjectDetailView(project: $project)) {
                                    ProjectRow(project: project)
                                }
                            }
                            .onDelete(perform: dataManager.deleteProject)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 6)
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

// --- ОБНОВЛЕННЫЙ ВИД ДЛЯ СТРОКИ В СПИСКЕ ПРОЕКТОВ ---
struct ProjectRow: View {
    let project: Project
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "film.stack.fill")
                .font(.title)
                .foregroundColor(.cyan)
                .frame(width: 44, height: 44)
                .background(Color.cyan.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(project.name)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(dateFormatter.string(from: project.date))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 12) {
                    Label("\(project.lensIDs.count)", systemImage: "camera.macro.circle")
                    Label("\(project.cameraIDs.count)", systemImage: "camera.circle")
                }
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}