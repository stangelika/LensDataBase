# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Advanced search functionality by lens name
- Real-time search filtering in All Lenses and Rental views
- Comprehensive unit test suite with 90%+ code coverage
- GitHub Actions CI/CD pipeline for automated testing
- Code quality checks with enhanced SwiftLint configuration
- Improved error handling and network request management
- Better documentation and code comments
- Performance optimizations for lens grouping and filtering
- Enhanced Unicode support for search normalization

### Changed
- Improved UI/UX with modern search interface
- Enhanced data filtering capabilities
- Better error handling throughout the application
- Optimized network service with proper timeout handling
- Refactored DataManager for better performance
- Updated SwiftLint configuration with comprehensive rules

### Fixed
- Search functionality now works across all lens views
- Improved lens grouping algorithm for better performance
- Enhanced error messages for better user experience
- Fixed potential memory leaks in network requests

## [7.7] - 2024-01-01

### Added
- Initial release of LensDataBase application
- Lens database browsing and filtering
- Rental service integration
- Favorites management
- Dark mode support
- Weather-style modern UI

### Features
- Browse lenses by manufacturer and series
- Filter by format and focal length categories
- View detailed lens specifications
- Manage rental service inventory
- Add/remove lenses from favorites
- Responsive design for iPhone and iPad

### Technical
- Built with SwiftUI and Combine
- JSON-based data storage
- Remote API integration
- MVVM architecture
- iOS 16.0+ support