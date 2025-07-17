# LensDataBase

A comprehensive iOS application for managing and browsing camera lens databases, built with SwiftUI for photographers and cinematographers.

## Features

### 🔍 Advanced Search & Filtering
- **Lens Name Search**: Search lenses by name with real-time filtering
- **Format Filtering**: Filter by lens format (Full Frame, Super35, etc.)
- **Focal Length Categories**: Filter by ultra-wide, wide, standard, tele, and super-tele lenses
- **Combined Filters**: Use multiple filters simultaneously for precise results

### 📱 Modern UI/UX
- **Weather-style Interface**: Modern, glass-morphism design with smooth animations
- **Dark Mode**: Optimized for low-light conditions
- **Responsive Layout**: Works seamlessly on iPhone and iPad
- **Gesture Support**: Intuitive touch interactions

### 🏪 Rental Services Integration
- **Rental Directory**: Browse available lenses by rental service
- **Availability Tracking**: See which lenses are available at specific locations
- **Contact Information**: Direct access to rental service details

### ⭐ Favorites System
- **Personal Collections**: Save favorite lenses for quick access
- **Persistent Storage**: Favorites are saved across app sessions
- **Quick Toggle**: One-tap favorite management

### 📊 Detailed Lens Information
- **Complete Specifications**: Focal length, aperture, close focus distance
- **Technical Details**: Image circle, front diameter, squeeze factor
- **Format Compatibility**: Full sensor format information
- **Physical Properties**: Length and weight specifications

## Technical Stack

- **Framework**: SwiftUI + Combine
- **Platform**: iOS 16.0+
- **Architecture**: MVVM with ObservableObject
- **Data**: JSON-based with remote API integration
- **Networking**: URLSession with Publisher pattern

## Installation

### Requirements
- iOS 16.0 or later
- iPhone or iPad
- Xcode 14.0+ (for development)

### Building from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/stangelika/LensDataBase.git
   cd LensDataBase
   ```

2. Open the project in Xcode:
   ```bash
   open Package.swift
   ```

3. Build and run the project in Xcode or use Swift Package Manager:
   ```bash
   swift build
   ```

## Usage

### Main Views

#### All Lenses View
- Browse complete lens database
- Search by lens name
- Filter by format and focal length
- Grouped by manufacturer and series

#### Rental View
- Select rental service
- View available inventory
- Search within specific rental locations
- Filter by format and specifications

#### Favorites View
- Access saved favorite lenses
- Quick search and filter capabilities
- Persistent across app sessions

#### Lens Detail View
- Complete lens specifications
- Technical information
- Rental availability
- Add/remove from favorites

### Search Functionality

The search feature allows you to:
- Search by lens name (case-insensitive)
- Use partial matches
- Combine with other filters
- Real-time results as you type

### Filtering Options

1. **Format Filter**: 
   - Full Frame (FF)
   - Super35
   - APS-C
   - Micro Four Thirds
   - Custom formats

2. **Focal Length Categories**:
   - Ultra Wide (≤12mm)
   - Wide (13–35mm)
   - Standard (36–70mm)
   - Tele (71–180mm)
   - Super Tele (181mm+)

## Data Sources

The app integrates with remote APIs to provide up-to-date lens information:
- **Lens Database**: Complete specifications and availability
- **Camera Database**: Compatible camera systems and formats
- **Rental Services**: Location and contact information

## Architecture

### Core Components

#### DataManager
- Centralized data management
- Network service integration
- State management
- Favorites persistence

#### Models
- **Lens**: Core lens data structure
- **Camera**: Camera system information
- **Rental**: Rental service details
- **AppData**: Main application data container

#### Views
- **AllLensesView**: Main lens browsing interface
- **RentalView**: Rental-specific lens browsing
- **FavoritesView**: Favorites management
- **LensDetailView**: Detailed lens information

### Data Flow
1. App launches → DataManager loads local data
2. User triggers refresh → Network service fetches remote data
3. User searches/filters → Real-time filtering applied
4. User selects lens → Detail view presented
5. User marks favorite → Persistent storage updated

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Standards
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Include documentation for public APIs
- Maintain consistent code formatting

## Testing

Run the test suite:
```bash
swift test
```

### Test Coverage
- Unit tests for data models
- Integration tests for network services
- UI tests for main user flows

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- SwiftUI community for inspiration
- Camera rental services for data partnerships
- Beta testers and feedback providers

## Support

For support, please open an issue on GitHub or contact the development team.

---

Made with ❤️ for photographers and cinematographers
