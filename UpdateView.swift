
import SwiftUI

struct UpdateView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            AppTheme.Colors.primaryGradient
            .ignoresSafeArea()

            VStack(spacing: 25) {
                HStack {
                    Text("Settings")
                    .font(.appLargeTitle)
                    .foregroundStyle(
                    LinearGradient(
                    colors: [AppTheme.Colors.primaryText, AppTheme.Colors.green.opacity(0.85), AppTheme.Colors.blue], startPoint: .leading, endPoint: .trailing
                    )
                    )
                    .shadow(color: AppTheme.Colors.green.opacity(0.18), radius: 12, x: 0, y: 6)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xxxl)
                .padding(.top, AppTheme.Spacing.padding22)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.Colors.green)
                        Text("Data Synchronization")
                        .font(.appHeadline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    }
                    Text("The application uses a local database of lenses and cameras for quick access. Press the button below to update the data from the server. This may take some time.")
                    .font(.appBody)
                    .foregroundColor(AppTheme.Colors.tertiaryText)
                    .lineSpacing(AppTheme.Spacing.sm)
                }
                .padding()
                .background(GlassBackground())
                .padding(.horizontal)

                Button(action: {
                    dataManager.refreshDataFromAPI()
                }
                ) {
                    HStack {
                        if dataManager.loadingState    == .loading {
                            ProgressView()
                            .tint(AppTheme.Colors.primaryText)
                        }
                        else {
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

                .disabled(dataManager.loadingState    == .loading)

                if case let .error(error) = dataManager.loadingState {
                    Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                }
                Spacer()
            }

        }
        .preferredColorScheme(.dark)
    }

}
