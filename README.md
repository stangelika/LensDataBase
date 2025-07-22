# LensDataBase - Professional Camera Lens Database

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Yes-green.svg)
![Platform](https://img.shields.io/badge/Platform-iPad%20%7C%20iPhone-lightgrey.svg)

A comprehensive Swift Playground application for browsing and managing professional camera lenses and rental information. Built specifically for filmmakers, photographers, and camera rental houses.

## 🎯 Features

### 📱 Core Functionality
- **Comprehensive Lens Database**: Browse thousands of professional cinema and photography lenses
- **Advanced Filtering**: Filter by focal length, format, manufacturer, and more
- **Favorites System**: Save lenses to your personal favorites list
- **Comparison Tool**: Compare multiple lenses side-by-side
- **Camera Compatibility**: Check lens compatibility with different camera systems
- **Rental Integration**: Find rental houses that carry specific lenses

### 🎨 User Experience
- **Modern SwiftUI Interface**: Clean, intuitive design optimized for iOS 18+
- **Adaptive Themes**: Light and dark mode support with custom accent colors
- **Weather-Style Lists**: Beautiful, weather app-inspired lens browsing
- **Responsive Design**: Works seamlessly on iPhone and iPad
- **Smooth Animations**: Polished transitions and interactions

### 📊 Data Management
- **Real-time API Integration**: Live data from professional lens databases
- **Local Caching**: Offline access to previously loaded data
- **Flexible Data Models**: Support for various lens formats and specifications
- **Error Handling**: Robust error handling with user-friendly messages

## 🚀 Getting Started

### Requirements
- iOS 18.0 or later
- Swift Playgrounds app (for iPad/iPhone)
- Xcode 15.0+ (for development)

### Installation Options

#### Option 1: Swift Playgrounds (Recommended for Users)
1. Download the Swift Playgrounds app from the App Store
2. Clone or download this repository
3. Open `LensDataBase.swiftpm` (original) or `LensDataBase-Refactored.swiftpm` (modern architecture) in Swift Playgrounds
4. Tap the play button to run the app

#### Option 2: Xcode (For Development)
1. Clone this repository:
   ```bash
   git clone https://github.com/stangelika/LensDataBase.git
   cd LensDataBase
   ```
2. Open `LensDataBase.swiftpm` or `LensDataBase-Refactored.swiftpm` in Xcode
3. Select your target device/simulator
4. Build and run (⌘+R)

## 🆕 Refactored Version

This repository now includes a completely refactored version (`LensDataBase-Refactored.swiftpm`) that demonstrates modern Swift and SwiftUI patterns:

### Key Improvements
- **Clean Architecture**: Separation of Domain, Data, and Presentation layers
- **Protocol-Oriented Design**: Better abstraction and testability
- **Modern Concurrency**: Async/await instead of Combine
- **Dependency Injection**: Loose coupling and easier testing
- **@Observable**: Modern SwiftUI state management (iOS 17+)
- **Enhanced Error Handling**: Typed errors with meaningful messages
- **Smart Caching**: Intelligent cache management with expiration

### Architectural Benefits
- **Better Testability**: Dependency injection enables comprehensive unit testing
- **Maintainability**: Modular structure makes changes safer and easier
- **Performance**: Improved caching and loading strategies
- **Scalability**: Architecture supports feature additions without major refactoring

For detailed information about the refactoring, see [REFACTORING_DOCUMENTATION.md](REFACTORING_DOCUMENTATION.md).

## 📁 Project Structure

### Original Implementation
```
LensDataBase.swiftpm/
├── 📱 App Core
│   ├── MyApp.swift              # Main app entry point
│   ├── Models.swift             # Data models and structures
│   ├── DataManager.swift        # Core data management
│   └── NetworkService.swift     # API networking layer
│
├── 🎨 User Interface
│   ├── MainTabView.swift        # Main navigation
│   ├── AllLensesView.swift      # Lens browsing interface
│   ├── LensDetailView.swift     # Detailed lens information
│   ├── FavoritesView.swift      # User favorites management
│   ├── ComparisonView.swift     # Lens comparison tool
│   └── CameraLensVisualizer.swift # Camera/lens compatibility
│
├── 🎨 Design System
│   ├── AppTheme.swift           # Color schemes and styling
│   ├── WeatherStyleLensListView.swift # Custom list components
│   └── FlatLensListView.swift   # Alternative list layouts
│
├── 📦 Resources
│   ├── Assets.xcassets/         # App icons and images
│   └── Resources/               # JSON data files
│
├── 🧪 Testing & Validation
│   ├── CompilationTest.swift    # Comprehensive test suite
│   ├── code_quality_check.sh   # Code quality validation
│   ├── validate_playground.sh  # Swift Playground validation
│   └── verify_project.sh       # Basic project verification
│
└── 📋 Configuration
    ├── Package.swift            # Swift Package configuration
    └── ThemeValidation.swift    # Theme system validation
```

### Refactored Implementation (Clean Architecture)
```
LensDataBase-Refactored.swiftpm/
├── 📱 App Entry
│   └── App.swift                # Modern app entry point
│
├── 🏗️ Domain Layer (Business Logic)
│   ├── Models/
│   │   └── DomainModels.swift   # Pure business entities
│   ├── Repository/
│   │   └── RepositoryProtocols.swift # Data access abstractions
│   └── UseCases/
│       └── DomainUseCases.swift # Business logic implementation
│
├── 📊 Data Layer (Data Access)
│   ├── Models/
│   │   └── APIModels.swift      # API response models
│   ├── Repository/
│   │   └── RepositoryImplementations.swift # Concrete repositories
│   ├── Services/
│   │   └── NetworkService.swift # Modern async networking + caching
│   └── DependencyContainer.swift # Dependency injection
│
├── 🎨 Presentation Layer (UI)
│   ├── ViewModels/
│   │   ├── LensListViewModel.swift     # Feature-specific view models
│   │   └── FeatureViewModels.swift     # Additional view models
│   └── Views/
│       ├── ContentView.swift           # Main navigation
│       ├── AppTheme.swift              # Modern design system
│       ├── FeatureViews.swift          # Feature-specific views
│       └── LensDetailView.swift        # Enhanced detail view
│
└── 📦 Resources
    └── CAMERADATA.json          # Local data files
```

## 🔧 Architecture

### Original Architecture (MVVM)
```
API/Local Data → NetworkService → DataManager → SwiftUI Views
```

### Refactored Architecture (Clean Architecture)
```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                     │
│  SwiftUI Views ←→ ViewModels (@Observable)              │
└─────────────────────────────────────────────────────────┘
                          ↕ Use Cases
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                         │
│  Business Logic ←→ Domain Models ←→ Repository Protocols│
└─────────────────────────────────────────────────────────┘
                          ↕ Repositories
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                          │
│  Network Service ←→ Cache Service ←→ API Models         │
└─────────────────────────────────────────────────────────┘
```

### Key Components

#### 🗃️ Original Data Layer
- **Models.swift**: Defines all data structures (Lens, Camera, Rental, etc.)
- **NetworkService.swift**: Handles API communication and data fetching
- **DataManager.swift**: Manages app state, filtering, and data transformation

#### 🗃️ Refactored Data Layer (Clean Architecture)
- **Domain Models**: Pure business entities with no external dependencies
- **Use Cases**: Encapsulated business logic (LensUseCase, FavoritesUseCase, etc.)
- **Repository Pattern**: Abstract data access with concrete implementations
- **Dependency Injection**: Loose coupling and better testability

#### 🎨 Presentation Layer
- **MainTabView.swift**: Top-level navigation container
- **AllLensesView.swift**: Primary lens browsing interface with advanced filtering
- **LensDetailView.swift**: Comprehensive lens specifications and details
- **FavoritesView.swift**: Personal lens collection management

#### 🎯 Business Logic Improvements
- **Use Cases Pattern**: Clean separation of business logic
- **Protocol-Oriented Design**: Better abstraction and testability
- **Async/Await**: Modern concurrency instead of Combine
- **Enhanced Error Handling**: Typed errors with meaningful messages
- **Smart Caching**: Intelligent cache management with expiration

## 🧪 Testing

### Running Tests
The project includes comprehensive test coverage:

```bash
# Run all validation scripts
./verify_project.sh          # Basic structure validation
./validate_playground.sh     # Swift Playground compatibility
./code_quality_check.sh      # Code quality and style analysis
```

### Test Categories
- **Unit Tests**: Core functionality and data model validation
- **Integration Tests**: API communication and data processing
- **UI Tests**: SwiftUI component functionality
- **Compatibility Tests**: Swift Playground and iOS version compatibility

### Test Coverage
- ✅ Data model initialization and validation
- ✅ Network service functionality
- ✅ Filtering and search algorithms
- ✅ Theme system validation
- ✅ Error handling scenarios
- ✅ Swift Playground compatibility

## 📡 API Integration

### Data Sources
- **Primary API**: `https://lksrental.site/api.php?action=all`
- **Local Fallback**: Bundled camera data in `Resources/CAMERADATA.json`

### Data Format
```json
{
  "success": true,
  "database": {
    "rentals": [...],
    "lenses": [...],
    "inventory": [...]
  }
}
```

### API Features
- Real-time lens database updates
- Rental house inventory information
- Camera compatibility data
- Automatic error recovery and caching

## 🎨 Customization

### Theme System
The app includes a comprehensive theme system supporting:
- Light and dark mode variants
- Custom accent colors
- Adaptive UI components
- Weather-style visual elements

### Adding Custom Themes
```swift
// In AppTheme.swift
extension AppTheme {
    static let customTheme = AppTheme(
        primary: .blue,
        secondary: .orange,
        background: .clear
    )
}
```

## 🔍 Development Guidelines

### Code Style
- Swift 5.9+ language features
- SwiftUI declarative UI patterns
- Combine for reactive programming
- MVVM architecture principles

### Best Practices
- Minimal external dependencies
- Comprehensive error handling
- Accessibility support
- Performance optimization for large datasets

### Quality Assurance
- Regular code quality checks via `code_quality_check.sh`
- Swift Playground compatibility validation
- Comprehensive test coverage
- Documentation maintenance

## 🚀 Deployment

### Swift Playground Distribution
1. Ensure all validation scripts pass
2. Verify iOS 18+ compatibility
3. Test on both iPhone and iPad
4. Package `.swiftpm` bundle for distribution

### App Store Considerations
While primarily designed for Swift Playgrounds, the project can be adapted for App Store distribution:
- Remove `AppleProductTypes` dependency
- Add proper app metadata
- Implement App Store guidelines compliance

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run all validation scripts
5. Submit a pull request

### Code Review Checklist
- [ ] All tests pass
- [ ] Code follows Swift style guidelines
- [ ] Documentation is updated
- [ ] Swift Playground compatibility maintained
- [ ] No breaking changes to existing functionality

## 📄 License

This project is available under the MIT License. See the LICENSE file for more details.

## 🙏 Acknowledgments

- Professional cinema lens database providers
- Swift Playgrounds team for the amazing development platform
- SwiftUI community for inspiration and best practices
- Open source contributors and testers

## 📞 Support

For questions, issues, or contributions:
- 📧 Create an issue on GitHub
- 💬 Join discussions in the repository
- 📖 Check the documentation in `/docs`

---

*Built with ❤️ using Swift Playgrounds and SwiftUI*