// ProjectSelectionView.swift

import SwiftUI

struct ProjectSelectionView: View {
    @Environment(\.dismiss) var dismiss // Для закрытия листа
    @EnvironmentObject var dataManager: DataManager
    let lensIDToAdd: String // ID объектива, который мы хотим добавить

    var body: some View {
        NavigationView {
            ZStack {
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
                    Text("Select a Project")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    if dataManager.projects.isEmpty {
                        Spacer()
                        Text("No projects available. Create one first!")
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(dataManager.projects) { project in
                                Button(action: {
                                    // Добавляем объектив в выбранный проект
                                    dataManager.addLens(lensIDToAdd, toProject: project)
                                    dismiss() // Закрываем лист после добавления
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(project.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("Lenses: \(project.lensIDs.count)")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        // Если объектив уже в проекте, показываем галочку
                                        if project.lensIDs.contains(lensIDToAdd) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss() // Закрываем лист
                        }
                        .foregroundColor(.cyan)
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .preferredColorScheme(.dark)
    }
}