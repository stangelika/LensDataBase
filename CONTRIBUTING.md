# Contributing to LensDataBase

Thank you for your interest in contributing to LensDataBase! We welcome contributions from the community.

## How to Contribute

### Reporting Bugs

Before submitting a bug report, please check if the issue has already been reported by searching through the existing issues.

When submitting a bug report, please include:
- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Screenshots or screen recordings if applicable
- iOS version and device model
- App version

### Suggesting Features

We welcome feature suggestions! Please check existing feature requests first.

When suggesting a feature:
- Provide a clear and descriptive title
- Explain the problem this feature would solve
- Describe the proposed solution
- Consider alternative solutions
- Explain why this feature would be useful

### Code Contributions

#### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/LensDataBase.git
   cd LensDataBase
   ```
3. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Open the project in Xcode
5. Make your changes
6. Test your changes thoroughly

#### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code formatting (run `swiftlint` before committing)
- Write clear, self-documenting code
- Add comments for complex logic
- Use meaningful variable and function names

#### Testing

- Write unit tests for new functionality
- Ensure all existing tests pass
- Test on multiple iOS versions and devices
- Include UI tests for user-facing features

#### Pull Request Process

1. Update documentation if needed
2. Update CHANGELOG.md with your changes
3. Ensure all tests pass
4. Update version numbers if applicable
5. Submit a pull request with:
   - Clear title and description
   - Reference to related issues
   - Screenshots/videos for UI changes
   - Test results

### Code Review Process

- All pull requests require review from maintainers
- We may request changes or improvements
- Please be patient and responsive to feedback
- Once approved, your changes will be merged

## Development Guidelines

### Architecture

- Use MVVM pattern with SwiftUI
- Separate concerns properly
- Use dependency injection where appropriate
- Follow reactive programming principles with Combine

### UI/UX

- Follow Apple's Human Interface Guidelines
- Ensure accessibility compliance
- Test on different screen sizes
- Maintain consistent design patterns

### Performance

- Optimize for smooth scrolling
- Handle large datasets efficiently
- Use lazy loading where appropriate
- Profile and test performance changes

### Data Management

- Validate all data inputs
- Handle network errors gracefully
- Implement proper error recovery
- Use appropriate data structures

## Questions?

If you have questions about contributing, please:
1. Check the existing documentation
2. Search through closed issues
3. Create a new issue with the "question" label

Thank you for contributing to LensDataBase! 🎉