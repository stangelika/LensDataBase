# LensDataBase Development Guide

## 🛠️ Development Setup

### Prerequisites
- **Xcode 15.0+** or **Swift Playgrounds** for iPad
- **iOS 18.0+** SDK
- **Swift 5.9+**
- Basic knowledge of SwiftUI and iOS development

### Quick Start
1. Clone repository: `git clone https://github.com/stangelika/LensDataBase.git`
2. Open `LensDataBase.swiftpm` in Swift Playgrounds or Xcode
3. Build and run the project

## 📁 Project Architecture

### Core Architecture Pattern: MVVM + Repository

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Views       │───▶│   ViewModels    │───▶│   Repository    │
│   (SwiftUI)     │    │ (DataManager)   │    │ (NetworkService)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Models       │    │    Business     │    │   Data Layer    │
│ (Lens, Camera)  │    │     Logic       │    │  (API/Cache)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### File Organization

#### 📱 App Core
- `MyApp.swift` - Application entry point and setup
- `MainTabView.swift` - Main navigation controller

#### 📊 Data Layer
- `Models.swift` - All data models, enums, and extensions
- `DataManager.swift` - Central data management and business logic
- `NetworkService.swift` - Network layer and API communication

#### 🎨 User Interface
- `SplashScreenView.swift` - App startup and loading
- `AllLensesView.swift` - Main lens browser
- `LensDetailView.swift` - Detailed lens information
- `FavoritesView.swift` - User favorites management
- `ComparisonView.swift` - Lens comparison tool
- `CameraLensVisualizer.swift` - Camera compatibility checker

#### 🎨 Design System
- `AppTheme.swift` - Complete theming system
- `ThemeValidation.swift` - Theme validation utilities

## 🧪 Testing Strategy

### Test Structure
```swift
// CompilationTest.swift
func runAllTests() {
    testBasicCompilation()     // Component instantiation
    testDataModels()          // Model validation
    testEnumValues()          // Enum consistency
    testLensOperations()      // Business logic
    testDataManagerFunctionality() // Data management
    testNetworkServiceSetup() // Network layer
}
```

### Running Tests
```swift
#if DEBUG
runAllTests() // Uncomment to run tests
#endif
```

### Test Categories

#### 🔧 Unit Tests
- **Model Tests**: Validate data model creation and properties
- **Enum Tests**: Verify all enum cases and display names
- **Extension Tests**: Test computed properties and methods

#### 🔗 Integration Tests
- **DataManager Tests**: Verify data loading and management
- **NetworkService Tests**: Test API integration
- **Search Tests**: Validate search functionality

#### 📱 UI Tests
- **Navigation Tests**: Verify tab switching and navigation
- **Theme Tests**: Check theme application and consistency
- **Accessibility Tests**: Validate VoiceOver support

## 🏗️ Code Guidelines

### Swift Style Guide

#### Naming Conventions
```swift
// ✅ Good
struct LensDetailView: View
class DataManager: ObservableObject
func searchLenses(query: String) -> [Lens]

// ❌ Bad  
struct lensDetail: View
class datamanager: ObservableObject
func search(q: String) -> [Lens]
```

#### Code Organization
```swift
// ✅ Structure your types like this
struct MyView: View {
    // MARK: - Properties
    @State private var selectedLens: Lens?
    
    // MARK: - Body
    var body: some View {
        // View implementation
    }
    
    // MARK: - Private Methods
    private func handleSelection(_ lens: Lens) {
        // Implementation
    }
}
```

#### SwiftUI Best Practices
```swift
// ✅ Use descriptive names for state
@State private var isShowingDetail = false
@State private var searchText = ""

// ✅ Extract complex views
var lensCard: some View {
    VStack {
        // Card implementation
    }
}

// ✅ Use proper modifiers order
Text("Lens Name")
    .font(.headline)
    .foregroundColor(.primary)
    .padding()
```

### Documentation Standards

#### Code Documentation
```swift
/**
 * Manages lens database operations and business logic
 * 
 * This class serves as the central data manager for the application,
 * handling data loading, searching, and state management.
 */
class DataManager: ObservableObject {
    
    /**
     * Searches lenses based on query string
     * - Parameter query: Search term to filter lenses
     * - Returns: Array of matching lenses
     */
    func searchLenses(query: String) -> [Lens] {
        // Implementation
    }
}
```

#### File Headers
```swift
//
//  DataManager.swift
//  LensDataBase
//
//  Manages lens database operations and search functionality.
//  Created as part of the LensDataBase Swift Playground project.
//

import Foundation
```

## 🎨 Theme System

### Theme Structure
```swift
struct AppTheme {
    let name: String
    let background: Color
    let surface: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let text: Color
    let textSecondary: Color
}
```

### Adding New Themes
```swift
extension AppTheme {
    static let customTheme = AppTheme(
        name: "Custom",
        background: Color(.systemBackground),
        surface: Color(.secondarySystemBackground),
        primary: Color(.systemBlue),
        secondary: Color(.systemGray),
        accent: Color(.systemGreen),
        text: Color(.label),
        textSecondary: Color(.secondaryLabel)
    )
}
```

### Theme Usage
```swift
struct MyView: View {
    @EnvironmentObject var theme: AppTheme
    
    var body: some View {
        VStack {
            Text("Hello")
                .foregroundColor(theme.text)
        }
        .background(theme.background)
    }
}
```

## 📊 Data Management

### DataManager Pattern
```swift
class DataManager: ObservableObject {
    @Published var lenses: [Lens] = []
    @Published var loadingState: DataLoadingState = .idle
    
    func loadData() {
        loadingState = .loading
        
        Task {
            do {
                let data = try await NetworkService.shared.fetchData()
                await MainActor.run {
                    self.lenses = data.lenses
                    self.loadingState = .loaded
                }
            } catch {
                await MainActor.run {
                    self.loadingState = .error
                }
            }
        }
    }
}
```

### Search Implementation
```swift
func searchLenses(query: String) -> [Lens] {
    guard !query.isEmpty else { return lenses }
    
    return lenses.filter { lens in
        lens.display_name.localizedCaseInsensitiveContains(query) ||
        lens.manufacturer.localizedCaseInsensitiveContains(query) ||
        lens.focal_length.contains(query)
    }
}
```

## 🔗 Network Layer

### NetworkService Structure
```swift
class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    func fetchData() async throws -> LensDatabase {
        // Implementation with proper error handling
    }
}
```

### Error Handling
```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        }
    }
}
```

## 🚀 Performance Optimization

### Memory Management
- Use `@StateObject` for data managers
- Use `@ObservedObject` for passed objects
- Implement proper `@Published` usage

### UI Performance
```swift
// ✅ Use LazyVStack for large lists
LazyVStack {
    ForEach(lenses) { lens in
        LensRowView(lens: lens)
    }
}

// ✅ Avoid unnecessary updates
struct LensRowView: View {
    let lens: Lens // Immutable
    
    var body: some View {
        // Implementation
    }
}
```

### Data Loading
```swift
// ✅ Use async/await properly
func loadData() async {
    do {
        let data = try await networkService.fetchData()
        await MainActor.run {
            self.lenses = data.lenses
        }
    } catch {
        // Handle error
    }
}
```

## 🔍 Debugging

### Debug Features
```swift
#if DEBUG
func debugPrint(_ message: String) {
    print("🐛 \(message)")
}
#endif
```

### Logging
```swift
enum LogLevel {
    case info, warning, error
}

func log(_ message: String, level: LogLevel = .info) {
    #if DEBUG
    let prefix = level == .error ? "❌" : level == .warning ? "⚠️" : "ℹ️"
    print("\(prefix) \(message)")
    #endif
}
```

## 📱 Platform Considerations

### Swift Playground Specific
- Uses `AppleProductTypes` for iOS app configuration
- Designed for iPad and iPhone compatibility
- Optimized for Swift Playgrounds environment

### iOS Deployment
- Minimum iOS 18.0 target
- Universal app (iPhone + iPad)
- Portrait and landscape support

## 🔧 Build & Deployment

### Pre-commit Checklist
```bash
# Run verification script
./verify_project.sh

# Run code quality check
./code_quality_check.sh

# Test compilation
# (Enable test run in CompilationTest.swift)
```

### Release Process
1. Update version in `Package.swift`
2. Run all quality checks
3. Test on physical devices
4. Update documentation
5. Create release notes

## 🐛 Common Issues & Solutions

### Build Issues
**Problem**: Module not found errors
**Solution**: Ensure proper Swift Playground structure

**Problem**: UI not updating
**Solution**: Check `@Published` and `@StateObject` usage

### Performance Issues
**Problem**: Slow scrolling in lists
**Solution**: Use `LazyVStack` and optimize row views

**Problem**: Memory leaks
**Solution**: Check retain cycles and proper object lifecycle

### Data Issues
**Problem**: Network requests failing
**Solution**: Check API endpoints and error handling

**Problem**: Search not working
**Solution**: Verify search implementation and data structure

## 📚 Resources

### Swift & SwiftUI
- [Swift Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Swift Playgrounds Guide](https://developer.apple.com/swift-playgrounds/)

### Design Patterns
- [iOS Architecture Patterns](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52)
- [MVVM in SwiftUI](https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-observedobject-to-manage-state-from-external-objects)

### Testing
- [Swift Testing Guide](https://developer.apple.com/documentation/xctest)
- [SwiftUI Testing](https://www.hackingwithswift.com/quick-start/swiftui/how-to-test-your-swiftui-views)

---

**Happy coding! 🚀**