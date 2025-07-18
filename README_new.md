# LensDataBase

A comprehensive iOS application for managing and browsing camera lens databases, built with SwiftUI for photographers and cinematographers.

## 🎯 Features

### 🔍 Advanced Search & Filtering
- **Lens Name Search**: Search lenses by name with real-time filtering
- **Format Filtering**: Filter by lens format (Full Frame, Super35, etc.)
- **Focal Length Categories**: Filter by ultra-wide, wide, standard, tele, and super-tele lenses
- **Combined Filters**: Use multiple filters simultaneously for precise results

### 📱 Modern UI/UX
- **Glass Morphism Design**: Beautiful, modern glass-effect interface
- **Centralized Theme System**: Consistent styling throughout the app
- **Dark Mode Optimized**: Designed for low-light conditions
- **Responsive Layout**: Works seamlessly on iPhone and iPad
- **Smooth Animations**: Fluid transitions and interactive elements

### 🏪 Rental Services Integration
- **Rental Directory**: Browse available lenses by rental service
- **Availability Tracking**: See which lenses are available at specific locations
- **Contact Information**: Direct access to rental service details

### ⭐ Favorites System
- **Personal Collections**: Save favorite lenses for quick access
- **Persistent Storage**: Favorites are saved across app sessions
- **Quick Toggle**: One-tap favorite management

### 📊 Project Management
- **Lens Collections**: Organize lenses into projects
- **Project Notes**: Add detailed notes to each project
- **Easy Management**: Create, edit, and delete projects
- **Data Persistence**: Projects are saved locally

### 📈 Detailed Lens Information
- **Complete Specifications**: Focal length, aperture, close focus distance
- **Technical Details**: Image circle, front diameter, squeeze factor
- **Format Compatibility**: Full sensor format information
- **Physical Properties**: Length and weight specifications

## 🏗️ Architecture

### Modern SwiftUI Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Combine Framework**: Reactive programming for data flow
- **ObservableObject**: SwiftUI state management
- **Centralized Theme**: Consistent design system

### Project Structure
```
LensDataBase/
├── Sources/LensDataBase/           # Modular source code
│   ├── Models/                     # Data models
│   ├── Services/                   # Business logic and networking
│   ├── Theme/                      # Centralized theme system
│   └── Components/                 # Reusable UI components
├── Tests/                          # Comprehensive test suite
├── Components/                     # iOS-specific components
├── Views/                          # SwiftUI views
├── Assets.xcassets/                # App assets
└── scripts/                        # Development scripts
```

### Core Components

#### 🎨 Theme System
- **AppTheme**: Centralized color, typography, and spacing system
- **Glass Morphism**: Consistent glass-effect styling
- **Responsive Design**: Adaptable to different screen sizes
- **Animation System**: Smooth, consistent animations

#### 📦 Reusable Components
- **GlassCard**: Glass morphism card container
- **GlassFilterChip**: Interactive filter buttons
- **SearchBar**: Consistent search interface
- **LensCard**: Standardized lens display

#### 🗄️ Data Management
- **DataManager**: Centralized data handling
- **NetworkService**: API integration
- **Local Storage**: Favorites and projects persistence
- **Error Handling**: Robust error management

## 🚀 Getting Started

### Prerequisites
- iOS 16.0 or later
- Xcode 14.0+ (for development)
- Swift 5.9+

### Installation

#### For Users
1. Clone the repository:
   ```bash
   git clone https://github.com/stangelika/LensDataBase.git
   cd LensDataBase
   ```

2. Open in Xcode:
   ```bash
   open Package.swift
   ```

3. Build and run the project

#### For Developers
1. Clone and navigate to the project:
   ```bash
   git clone https://github.com/stangelika/LensDataBase.git
   cd LensDataBase
   ```

2. Install development dependencies:
   ```bash
   # Install SwiftLint and SwiftFormat (macOS only)
   brew install swiftlint swiftformat
   ```

3. Run tests:
   ```bash
   # iOS tests (requires Xcode)
   ./scripts/test.sh
   
   # Cross-platform tests
   cp Package.test.swift Package.swift
   swift test
   ```

4. Check code quality:
   ```bash
   ./scripts/quality.sh
   ```

## 🧪 Testing

### Test Coverage
- **15 comprehensive tests** covering core functionality
- **Model validation** for all data structures
- **JSON decoding** with flexible type handling
- **Data filtering** and sorting operations
- **State management** verification
- **Performance testing** for large datasets

### Running Tests
```bash
# Run all tests
swift test

# Run with coverage
swift test --enable-code-coverage

# Run iOS-specific tests (macOS only)
xcodebuild -scheme LensDataBase \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  test -enableCodeCoverage YES
```

## 🔧 Development

### Code Quality
- **SwiftLint**: Code style enforcement
- **SwiftFormat**: Consistent code formatting
- **Comprehensive tests**: High test coverage
- **Documentation**: Detailed code documentation

### CI/CD Pipeline
- **GitHub Actions**: Automated testing and building
- **Code quality checks**: Automated linting and formatting
- **Test coverage reporting**: Comprehensive coverage analysis
- **Security scanning**: Vulnerability detection

### Contributing
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Run tests: `./scripts/test.sh`
4. Check code quality: `./scripts/quality.sh`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📚 API Reference

### Data Models

#### Lens
```swift
struct Lens: Codable, Identifiable {
    let id: String
    let display_name: String
    let manufacturer: String
    let focal_length: String
    let aperture: String
    // ... additional properties
}
```

#### Project
```swift
struct Project: Codable, Identifiable {
    let id: UUID
    var name: String
    var notes: String
    var lensIDs: [String]
    var cameraIDs: [String]
}
```

### Theme System

#### Colors
```swift
AppTheme.Colors.primary           // Primary brand color
AppTheme.Colors.backgroundPrimary // Main background
AppTheme.Colors.textPrimary      // Primary text color
AppTheme.Colors.accent           // Accent color
```

#### Typography
```swift
AppTheme.Typography.displayLarge  // Large display text
AppTheme.Typography.headlineLarge // Headlines
AppTheme.Typography.bodyLarge     // Body text
```

#### Spacing
```swift
AppTheme.Spacing.xs    // 4pt
AppTheme.Spacing.sm    // 8pt
AppTheme.Spacing.md    // 16pt
AppTheme.Spacing.lg    // 24pt
AppTheme.Spacing.xl    // 32pt
```

## 🎨 Design System

### Glass Morphism
The app uses a consistent glass morphism design language:
- **Translucent surfaces** with subtle blur effects
- **Consistent corner radius** and border styling
- **Layered depth** with appropriate shadows
- **Interactive feedback** with smooth animations

### Color Palette
- **Primary**: Deep blues and purples
- **Secondary**: Subtle grays and whites
- **Accent**: Vibrant green for highlights
- **Background**: Rich dark gradients

### Typography
- **Display**: Heavy rounded fonts for headers
- **Body**: Clean, readable fonts for content
- **Labels**: Medium weight for interactive elements

## 🛠️ Technical Stack

- **Framework**: SwiftUI + Combine
- **Platform**: iOS 16.0+
- **Architecture**: MVVM with centralized state management
- **Data**: JSON-based with remote API integration
- **Storage**: UserDefaults for local persistence
- **Testing**: XCTest with comprehensive coverage
- **CI/CD**: GitHub Actions

## 📈 Performance

### Optimizations
- **Efficient data loading** with background processing
- **Lazy loading** for large datasets
- **Memory management** with proper resource cleanup
- **Smooth animations** with optimized rendering
- **Responsive UI** with minimal blocking operations

### Benchmarks
- **Startup time**: < 2 seconds on average devices
- **Search performance**: Real-time filtering of 1000+ lenses
- **Memory usage**: Optimized for iOS memory constraints
- **Battery efficiency**: Minimal background processing

## 🔐 Privacy & Security

- **Local data storage**: Sensitive data stays on device
- **No personal information** collection beyond preferences
- **Secure API calls** with proper error handling
- **No third-party tracking** or analytics

## 🤝 Support

For support, please:
1. Check the [Issues](https://github.com/stangelika/LensDataBase/issues) page
2. Create a new issue with detailed information
3. Include device information and steps to reproduce

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- SwiftUI community for inspiration and best practices
- Camera rental services for data partnerships
- Beta testers and feedback providers
- Open source contributors

---

Made with ❤️ for photographers and cinematographers

**Version**: 7.7  
**Last Updated**: 2024  
**Minimum iOS**: 16.0