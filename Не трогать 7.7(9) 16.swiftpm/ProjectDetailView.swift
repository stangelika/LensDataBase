// ProjectDetailView.swift (ПОЛНЫЙ КОД С ИЗМЕНЕНИЯМИ)

import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var project: Project
    
    // Переменные состояния для алерта и закрытия вида
    @State private var showingCameraSelection = false
    @State private var showingDeleteAlert = false // ✅ НОВАЯ ПЕРЕМЕННАЯ
    @Environment(\.dismiss) var dismiss

    var body: some View {
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

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Заголовок проекта
                    HStack {
                        Spacer().frame(width: 50)
                        TextField("Project Name", text: $project.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .cyan.opacity(0.2), radius: 5)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    
                    // ... (остальной код для даты, заметок, объективов и камер без изменений)
                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.15)).padding(.horizontal).padding(.bottom, 10)
                    HStack {
                        Label("Project Date", systemImage: "calendar").font(.headline).foregroundColor(.white.opacity(0.8))
                        Spacer()
                        DatePicker("Project Date", selection: $project.date, displayedComponents: .date).labelsHidden().tint(.cyan).onChange(of: project.date) { _ in dataManager.saveProjects() }
                    }.padding(.vertical, 10).padding(.horizontal, 16).background(Color.white.opacity(0.08)).cornerRadius(12).padding(.horizontal)
                    TextEditor(text: $project.notes).font(.body).foregroundColor(.white.opacity(0.8)).padding().background(Color.white.opacity(0.08)).cornerRadius(10).frame(minHeight: 150).padding(.horizontal).onChange(of: project.notes) { _ in dataManager.saveProjects() }
                    Text("Lenses (\(project.lensIDs.count))").font(.headline).foregroundColor(.white).padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            if project.lensIDs.isEmpty {
                                PlaceholderCard(text: "No lenses added yet.", subtext: "Add lenses from their detail pages.")
                            } else {
                                ForEach(project.lensIDs, id: \.self) { lensID in
                                    if let lens = dataManager.availableLenses.first(where: { $0.id == lensID }) { ProjectLensCard(lens: lens) }
                                }
                            }
                        }.padding(.horizontal)
                    }.frame(height: 100)
                    Text("Cameras (\(project.cameraIDs.count))").font(.headline).foregroundColor(.white).padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            if project.cameraIDs.isEmpty {
                                PlaceholderCard(text: "No cameras added yet.", subtext: "Tap 'Add Camera' below.")
                            } else {
                                ForEach(project.cameraIDs, id: \.self) { cameraID in
                                    if let camera = dataManager.cameras.first(where: { $0.id == cameraID }) { ProjectCameraCard(camera: camera) }
                                }
                            }
                            Button(action: { showingCameraSelection = true }) { AddItemCard(icon: "camera.badge.plus", text: "Add Camera") }
                        }.padding(.horizontal)
                    }.frame(height: 100)
                    // ... (конец неизмененного кода)
                    
                    Spacer(minLength: 40)

                    // ✅ НАЧАЛО: НОВЫЙ БЛОК ДЛЯ УДАЛЕНИЯ ПРОЕКТА
                    VStack(spacing: 4) {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete Project")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.15))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)

                        Text("This action cannot be undone.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom)
                    // ✅ КОНЕЦ: НОВЫЙ БЛОК
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingCameraSelection) {
            CameraSelectionView(project: $project)
                .environmentObject(dataManager)
        }
        // ✅ НОВЫЙ МОДИФИКАТОР ДЛЯ ПОКАЗА АЛЕРТА
        .alert("Delete Project?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                // Вызываем новый метод удаления по ID
                dataManager.deleteProject(withId: project.id)
                // Закрываем текущий экран
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete the project “\(project.name)”?")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .onChange(of: project.name) { _ in
            dataManager.saveProjects()
        }
    }
}


// --- КОМПОНЕНТЫ ДЛЯ ЭКРАНА (без изменений) ---

struct ProjectLensCard: View {
    let lens: Lens
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lens.display_name).font(.headline).foregroundColor(.white).lineLimit(2).minimumScaleFactor(0.8)
            Spacer()
            Text(lens.format).font(.caption.weight(.semibold)).foregroundColor(.white.opacity(0.7)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.cyan.opacity(0.3)).clipShape(Capsule())
        }
        .padding(12).frame(width: 160, height: 100).background(Color.white.opacity(0.08)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan.opacity(0.4), lineWidth: 1))
    }
}

struct ProjectCameraCard: View {
    let camera: Camera
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(camera.manufacturer) \(camera.model)").font(.headline).foregroundColor(.white).lineLimit(2).minimumScaleFactor(0.8)
            Spacer()
            Text(camera.sensor).font(.caption.weight(.semibold)).foregroundColor(.white.opacity(0.7)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.green.opacity(0.3)).clipShape(Capsule())
        }
        .padding(12).frame(width: 160, height: 100).background(Color.white.opacity(0.08)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.4), lineWidth: 1))
    }
}

struct PlaceholderCard: View {
    let text: String
    let subtext: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(text).foregroundColor(.white.opacity(0.6))
            Text(subtext).font(.caption).foregroundColor(.white.opacity(0.4))
        }
        .padding().frame(width: 200, height: 100).background(Color.white.opacity(0.05)).cornerRadius(12)
    }
}

struct AddItemCard: View {
    let icon: String
    let text: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title).foregroundColor(.green)
            Text(text).font(.headline).foregroundColor(.white)
        }
        .frame(width: 160, height: 100).background(Color.white.opacity(0.08)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5])))
    }
}