import SwiftUI

struct UpdateView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            createBackgroundGradient()
            
            VStack(spacing: 25) {
                createHeaderSection()
                createDescriptionCard()
                createUpdateButton()
                createErrorMessage()
                Spacer()
            }
        }
    }
    
    // MARK: - UI Components
    
    private func createBackgroundGradient() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 24/255, green: 27/255, blue: 37/255, opacity: 1),
                Color(.sRGB, red: 34/255, green: 37/255, blue: 57/255, opacity: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func createHeaderSection() -> some View {
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
    }
    
    private func createDescriptionCard() -> some View {
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
    }
    
    private func createUpdateButton() -> some View {
        Button(action: {
            dataManager.refreshDataFromAPI()
        }) {
            HStack {
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
        .disabled(dataManager.loadingState == .loading)
    }
    
    private func createErrorMessage() -> some View {
        Group {
            if case .error(let error) = dataManager.loadingState {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

// MARK: - Supporting Views

/// Glass background component for cards
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