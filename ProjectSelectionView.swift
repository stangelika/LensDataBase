// ProjectSelectionView.swift

import SwiftUI

struct ProjectSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    // ID объектива, который мы хотим добавить
    let lensIDToAdd: String
    
    // Состояние для поля ввода нового проекта
    @State private var newProjectName: String = ""

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

                VStack(spacing: 0) {
                    // Заголовок
                    Text("Add to Project")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding()

                    // Список проектов
                    ScrollView {
                        VStack(spacing: 12) {
                            if dataManager.projects.isEmpty {
                                Text("No projects yet.\nCreate one below!")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.vertical, 50)
                            } else {
                                // Используем ForEach с Binding ($), чтобы изменения сразу отражались
                                ForEach($dataManager.projects) { $project in
                                    ProjectSelectionRow(project: $project, lensID: lensIDToAdd)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Футер для создания нового проекта
                    VStack(spacing: 12) {
                        Divider().background(Color.white.opacity(0.2))
                        
                        HStack {
                            TextField("New Project Name", text: $newProjectName)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .submitLabel(.done) // Меняем кнопку "return" на "Done"

                            Button(action: createNewProjectAndAddLens) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green)
                            }
                            .disabled(newProjectName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(newProjectName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                            .animation(.easeInOut, value: newProjectName.isEmpty)
                        }
                        .padding()
                    }
                    .background(.ultraThinMaterial)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.cyan)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("")
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear {
            // Сохраняем все изменения при закрытии окна
            dataManager.saveProjects()
        }
    }
    
    private func createNewProjectAndAddLens() {
        let trimmedName = newProjectName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Создаем новый проект
        var newProject = Project(name: trimmedName)
        
        // Сразу добавляем в него текущий объектив
        newProject.lensIDs.append(lensIDToAdd)
        
        // Добавляем проект в начало списка
        dataManager.projects.insert(newProject, at: 0)
        
        // Очищаем поле ввода
        newProjectName = ""
        
        // Убираем фокус с текстового поля
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Кастомная строка для списка выбора проектов
struct ProjectSelectionRow: View {
    @Binding var project: Project
    let lensID: String
    
    private var isLensInProject: Bool {
        project.lensIDs.contains(lensID)
    }

    var body: some View {
        Button(action: toggleLensInProject) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline.weight(.bold))
                    Text("Contains \(project.lensIDs.count) lenses")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: isLensInProject ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isLensInProject ? .green : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isLensInProject ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isLensInProject ? Color.green : Color.clear, lineWidth: 2)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isLensInProject)
    }
    
    private func toggleLensInProject() {
        if let index = project.lensIDs.firstIndex(of: lensID) {
            project.lensIDs.remove(at: index)
        } else {
            project.lensIDs.append(lensID)
        }
    }
}