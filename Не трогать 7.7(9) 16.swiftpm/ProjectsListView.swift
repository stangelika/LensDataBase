// ProjectsListView.swift

import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddProjectView = false // Переменная для контроля видимости окна

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
                            ForEach($dataManager.projects) { $project in
                                NavigationLink(destination: ProjectDetailView(project: $project)) {
                                    ProjectRow(project: project)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 6)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Кнопка теперь показывает всплывающее окно
                        Button(action: {
                            showingAddProjectView = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .blur(radius: showingAddProjectView ? 10 : 0) // Эффект размытия фона
                
                // Секция для показа всплывающего окна
                if showingAddProjectView {
                    // Затемненный фон, который можно нажать для закрытия
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { showingAddProjectView = false }
                    
                    // Само окно
                    AddProjectView(isPresented: $showingAddProjectView)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            // Анимация для плавного появления и исчезновения
            .animation(.spring(), value: showingAddProjectView)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
}

// MARK: - AddProjectView
struct AddProjectView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool
    
    @State private var projectName: String = ""
    @FocusState private var isFocused: Bool // Для автоматической активации клавиатуры

    var body: some View {
        VStack(spacing: 20) {
            Text("New Project")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            TextField("Enter project name", text: $projectName)
                .focused($isFocused)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .tint(.cyan)
                .submitLabel(.done) // Меняем кнопку на клавиатуре на "Готово"

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)

                Button("Create") {
                    if !projectName.trimmingCharacters(in: .whitespaces).isEmpty {
                        dataManager.addProject(withName: projectName)
                        isPresented = false
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cyan)
                .foregroundColor(.black)
                .cornerRadius(12)
                .font(.headline.weight(.bold))
                .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(projectName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 30)
        .onAppear {
            // Небольшая задержка для плавной анимации появления клавиатуры
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}


// MARK: - ProjectRow
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