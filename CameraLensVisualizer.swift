import SwiftUI

 enum ExpandedPicker {
    case camera
    case format
}

struct CameraLensVisualizerRoot: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    let lens: Lens
    
    @State private var selectedCamera: Camera?
    @State private var selectedFormat: RecordingFormat?
    
    @State private var activePicker: ExpandedPicker? = nil
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Шапка
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Text("Проверка совместимости").font(.title3.weight(.semibold)).foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer().frame(height: 20)
                    
                    // Карточка объектива
                    GlassInfoCard(
                        title: lens.display_name,
                        subtitle: "\(lens.manufacturer) \(lens.lens_name)",
                        icon: "camera.metering.matrix",
                        value: "Круг изображения: \(lens.image_circle)"
                    )
                    .padding(.horizontal)
                    
                    // Визуализация
                    if let format = selectedFormat {
                        ZStack {
                            Rectangle().fill(Color.clear).frame(height: 220)
                            
                            GeometryReader { geo in
                                ZStack {
                                    let lensCircleDiameter = lens.validImageCircle
                                    let formatDiagonal = format.recordingDiagonal
                                    let maxDimension = max(lensCircleDiameter ?? 0, formatDiagonal ?? 0)

                                    if maxDimension > 0 {
                                        let scaleFactor = geo.size.height / (maxDimension * 1.2)
                                        if let ic = lensCircleDiameter {
                                            let circleDiameter = CGFloat(ic) * CGFloat(scaleFactor)
                                            Circle()
                                                .strokeBorder(Color.blue, lineWidth: 3)
                                                .background(Circle().fill(Color.blue.opacity(0.1)))
                                                .frame(width: circleDiameter, height: circleDiameter)
                                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        }
                                        if let w = format.validRecordingWidth, let h = format.validRecordingHeight {
                                            let rectWidth = CGFloat(w) * CGFloat(scaleFactor)
                                            let rectHeight = CGFloat(h) * CGFloat(scaleFactor)
                                            RoundedRectangle(cornerRadius: 4)
                                                .strokeBorder(Color.yellow, lineWidth: 3)
                                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.yellow.opacity(0.15)))
                                                .frame(width: rectWidth, height: rectHeight)
                                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Блок выбора камеры и формата
                    VStack(spacing: 12) {
                        ExpandablePickerView(
                            pickerId: .camera,
                            title: "Камера",
                            icon: "camera",
                            data: dataManager.cameras,
                            selection: $selectedCamera,
                            activePicker: $activePicker,
                            selectionDisplay: { camera in
                                "\(camera.manufacturer) \(camera.model)"
                            },
                            content: { camera in
                                PickerRowView(
                                    text: "\(camera.manufacturer) \(camera.model)",
                                    isSelected: selectedCamera?.id == camera.id
                                )
                            }
                        )
                        
                        if let camera = selectedCamera {
                            ExpandablePickerView(
                                pickerId: .format,
                                title: "Формат",
                                icon: "aspectratio",
                                data: dataManager.formats.filter { $0.cameraId == camera.id },
                                selection: $selectedFormat,
                                activePicker: $activePicker,
                                selectionDisplay: { format in
                                    format.recordingFormat
                                },
                                content: { format in
                                    PickerRowView(
                                        text: "\(format.recordingFormat) (\(format.recordingWidth)x\(format.recordingHeight)мм)",
                                        isSelected: selectedFormat?.id == format.id
                                    )
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Информационная карточка
                    if let format = selectedFormat, let camera = selectedCamera {
                        GlassInfoCard(
                            title: "\(camera.manufacturer) \(camera.model)",
                            subtitle: format.recordingFormat,
                            icon: "camera",
                            value: {
                                let w = format.recordingWidth
                                let h = format.recordingHeight
                                let diag = format.recordingDiagonal.map { String(format: "%.1f мм", $0) } ?? "-"
                                return "\(w)x\(h) мм (диаг. \(diag))"
                            }(),
                            status: {
                                guard let lensCircle = lens.validImageCircle,
                                      let formatDiag = format.recordingDiagonal else {
                                    return nil
                                }
                                return lensCircle >= formatDiag ?
                                    (true, "Полное покрытие", "checkmark.circle.fill") :
                                    (false, "Возможна виньетка", "xmark.circle.fill")
                            }()
                        )
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 28/255, green: 32/255, blue: 48/255),
                        Color(.sRGB, red: 38/255, green: 36/255, blue: 97/255)
                    ]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .onAppear {
                if selectedCamera == nil {
                    selectedCamera = dataManager.cameras.first
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onChange(of: selectedCamera) { camera in
            if let cam = camera {
                selectedFormat = dataManager.formats.first(where: { $0.cameraId == cam.id })
            }
        }
    }
}

// ... остальной код файла (компоненты ExpandablePickerView, PickerRowView, GlassInfoCard и т.д.) без изменений ...

// --- КОМПОНЕНТЫ ДЛЯ СПИСКОВ ---

struct ExpandablePickerView<Data, Content: View>: View where Data: Hashable, Data: Identifiable {
    let pickerId: ExpandedPicker
    let title: String
    let icon: String
    let data: [Data]
    @Binding var selection: Data?
    @Binding var activePicker: ExpandedPicker?
    let selectionDisplay: (Data) -> String
    let content: (Data) -> Content
    
    private var isExpanded: Bool {
        activePicker == pickerId
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) {
                    activePicker = isExpanded ? nil : pickerId
                }
            }) {
                HStack {
                    Image(systemName: icon).font(.headline.weight(.semibold)).foregroundColor(.white.opacity(0.8)).frame(width: 20)
                    Text(title).font(.headline).foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(selection != nil ? selectionDisplay(selection!) : "Выберите...").font(.headline.weight(.medium)).foregroundColor(.white).lineLimit(1)
                    Image(systemName: "chevron.up.chevron.down").font(.system(size: 14, weight: .bold)).foregroundColor(.white.opacity(0.7)).rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(GlassBackground())
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(data) { item in
                            self.content(item)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.33, dampingFraction: 0.8)) {
                                        self.selection = item
                                        self.activePicker = nil
                                    }
                                }
                        }
                    }
                }
                .frame(maxHeight: 250)
                .padding(6)
                .background(GlassBackground())
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct PickerRowView: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline.weight(isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .blue : .white)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.2))
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


// --- ОСТАЛЬНЫЕ КОМПОНЕНТЫ ---

struct GlassInfoCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    var status: (isCompatible: Bool, statusText: String, icon: String)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                if let status = status {
                    HStack(spacing: 6) {
                        Image(systemName: status.icon)
                            .foregroundColor(status.isCompatible ? .green : .red)
                        Text(status.statusText)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(status.isCompatible ? .green : .red)
                    }
                }
            }
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Divider()
                .background(Color.white.opacity(0.2))
            Text(value)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct GlassBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
            .shadow(color: Color.white.opacity(0.08), radius: 7, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

extension Lens {
    var validImageCircle: Double? {
        let cleanedValue = image_circle
            .lowercased()
            .replacingOccurrences(of: "mm", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedValue.isEmpty, cleanedValue != "-" else { return nil }
        return Double(cleanedValue)
    }
}

extension RecordingFormat {
    var validRecordingWidth: Double? { cleanAndConvertToDouble(recordingWidth) }
    var validRecordingHeight: Double? { cleanAndConvertToDouble(recordingHeight) }
    
    var recordingDiagonal: Double? {
        guard let width = validRecordingWidth, let height = validRecordingHeight else { return nil }
        guard width > 0 && height > 0 else { return nil }
        return sqrt(width * width + height * height)
    }
    
    private func cleanAndConvertToDouble(_ value: String) -> Double? {
        let cleaned = value
            .lowercased()
            .replacingOccurrences(of: "mm", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleaned.isEmpty, cleaned != "-" else { return nil }
        return Double(cleaned)
    }
}

struct ApiError: Codable {
    let success: Bool
    let error: String
}
