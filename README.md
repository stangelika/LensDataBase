# LensDataBase Swift Playground

A comprehensive iOS application for managing and exploring cinema lens databases, built as a Swift Playground project.

## 📱 Overview

LensDataBase is a modern iOS application that allows users to browse, compare, and manage cinema lenses from various manufacturers. The app provides detailed lens specifications, camera compatibility information, and rental house contacts.

## ✨ Features

- **Comprehensive Lens Database**: Browse thousands of cinema lenses with detailed specifications
- **Advanced Search & Filtering**: Find lenses by focal length, aperture, format, and manufacturer
- **Camera Compatibility**: Visual compatibility checker between lenses and cameras
- **Favorites Management**: Save and organize your preferred lenses
- **Lens Comparison**: Side-by-side comparison of multiple lenses
- **Rental Integration**: Find rental houses that stock specific lenses
- **Multiple View Modes**: Weather-style grouped view and flat list view
- **Modern UI/UX**: Clean, intuitive interface with customizable themes

## 🏗️ Architecture

### Project Structure

```
LensDataBase.swiftpm/
├── 📱 App Core
│   ├── MyApp.swift              # App entry point
│   ├── Package.swift            # Swift Package configuration
│   └── MainTabView.swift        # Main navigation
│
├── 📊 Data Layer
│   ├── Models.swift             # Data models and enums
│   ├── DataManager.swift        # Data management & business logic
│   └── NetworkService.swift     # Network operations
│
├── 🎨 User Interface
│   ├── SplashScreenView.swift   # App startup screen
│   ├── AllLensesView.swift      # Main lens listing
│   ├── LensDetailView.swift     # Detailed lens information
│   ├── FavoritesView.swift      # Favorites management
│   ├── ComparisonView.swift     # Lens comparison
│   ├── CameraLensVisualizer.swift # Camera compatibility
│   ├── RentalAndSettingsView.swift # Settings & rentals
│   ├── WeatherStyleLensListView.swift # Grouped lens view
│   └── FlatLensListView.swift   # Simple list view
│
├── 🎨 Design System
│   ├── AppTheme.swift           # Theme definitions
│   └── ThemeValidation.swift    # Theme validation utilities
│
├── 🧪 Testing & Validation
│   ├── CompilationTest.swift    # Comprehensive test suite
│   └── verify_project.sh        # Project verification script
│
└── 📁 Resources
    └── CAMERADATA.json          # Camera database
```

### Key Components

#### Data Models
- **Lens**: Cinema lens specifications and metadata
- **Camera**: Camera sensor information and compatibility data
- **Rental**: Rental house contact information
- **RecordingFormat**: Camera recording format specifications

#### Business Logic
- **DataManager**: Centralized data management, search, and filtering
- **NetworkService**: API communication and data fetching
- **Search Algorithm**: Intelligent lens search with multiple criteria

#### User Interface
- **Theme System**: Customizable appearance with multiple themes
- **Responsive Design**: Optimized for both iPhone and iPad
- **Accessibility**: Full VoiceOver and accessibility support

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+** or **Swift Playgrounds** on iPad
- **iOS 18.0+** deployment target
- **Swift 5.9+**

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/stangelika/LensDataBase.git
   cd LensDataBase
   ```

2. **Open in Swift Playgrounds**:
   - Open the `LensDataBase.swiftpm` folder in Swift Playgrounds
   - The project will automatically configure and build

3. **Alternative: Open in Xcode**:
   - Double-click `LensDataBase.swiftpm` to open in Xcode
   - Build and run the project

### First Run
The app will display a splash screen while loading the lens database. The initial data load may take a few moments depending on your internet connection.

## 🧪 Testing

### Running Tests
The project includes a comprehensive test suite in `CompilationTest.swift`:

```swift
// To run all tests (in DEBUG mode):
runAllTests()
```

### Test Coverage
- ✅ **Compilation Tests**: Verify all components compile correctly
- ✅ **Data Model Tests**: Validate model creation and properties
- ✅ **Enum Tests**: Check all enum values and display names
- ✅ **Lens Operations**: Test focal length calculations and operations
- ✅ **DataManager**: Verify data management functionality
- ✅ **NetworkService**: Test network service setup

### Project Verification
Run the verification script to check project structure:

```bash
cd LensDataBase.swiftpm
./verify_project.sh
```

## 📖 API Documentation

### Lens Database API

The app connects to a lens database API that provides:

#### Data Structure
```json
{
  "success": true,
  "database": {
    "lenses": [...],
    "rentals": [...],
    "inventory": [...]
  }
}
```

#### Key Fields

**Lenses Table**:
- `id`: Unique identifier
- `display_name`: Display name
- `manufacturer`: Lens manufacturer
- `focal_length`: Focal length (mm)
- `aperture`: Maximum aperture (f-stop)
- `format`: Sensor format (FF, S35, MFT, etc.)
- `close_focus_cm`: Minimum focus distance (cm)
- `image_circle`: Image circle diameter (mm)

For complete API documentation, see [API_KEYS_DOCUMENTATION_Version3.md](API_KEYS_DOCUMENTATION_Version3.md).

## 🎨 Themes & Customization

The app supports multiple themes:
- **Light Theme**: Clean, modern light interface
- **Dark Theme**: OLED-friendly dark interface
- **Custom Themes**: Extensible theme system

### Adding Custom Themes
Extend the `AppTheme` structure to add new themes:

```swift
extension AppTheme {
    static let myCustomTheme = AppTheme(
        name: "Custom",
        background: Color.myBackground,
        // ... other theme properties
    )
}
```

## 🔧 Development

### Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Maintain consistent indentation (4 spaces)

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Quality Checks
- Run `./verify_project.sh` before committing
- Test all functionality on both iPhone and iPad
- Verify accessibility with VoiceOver
- Check performance with large datasets

## 📊 Project Statistics

- **18 Swift files** with **2,949 lines of code**
- **Clean architecture** with separation of concerns
- **100% Swift** - no external dependencies
- **Responsive design** for iPhone and iPad
- **iOS 18+ compatible** with modern SwiftUI features

## 🐛 Troubleshooting

### Common Issues

**App won't load data**:
- Check internet connection
- Verify API endpoint accessibility
- Review network permissions

**Performance issues**:
- Clear app cache and restart
- Check device storage space
- Update to latest iOS version

**Build issues in Xcode**:
- Clean build folder (⌘+Shift+K)
- Restart Xcode
- Ensure Xcode 15.0+ is installed

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♀️ Support

For questions, issues, or feature requests:
- Open an issue on GitHub
- Check existing documentation
- Review the troubleshooting section

## 🏆 Acknowledgments

- Thanks to all lens manufacturers for specifications
- Cinema lens rental houses for inventory data
- The Swift and SwiftUI community for inspiration
- All contributors and testers

---

**Built with ❤️ using Swift and SwiftUI**