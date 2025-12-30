# Contributing to DeskPro

First off, thank you for considering contributing to DeskPro! It's people like you that make DeskPro such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide specific examples**
* **Describe the behavior you observed and what you expected**
* **Include screenshots and animated GIFs if possible**
* **Include your environment details** (OS, Flutter version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a detailed description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior and explain the behavior you expected**
* **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## Development Process

### Setting Up Your Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/DeskPro.git
cd DeskPro

# Install Flutter dependencies
flutter pub get

# Install Node.js dependencies for signaling server
cd signaling_server
npm install
cd ..

# Run the app
flutter run
```

### Project Structure

```
lib/
├── core/           # Constants, theme, utilities
├── data/           # Models, services
└── presentation/   # UI screens, widgets, providers
```

### Coding Standards

* Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
* Use meaningful variable and function names
* Comment complex logic
* Keep functions small and focused
* Write self-documenting code when possible

### Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

Examples:
```
Add file sharing progress indicator
Fix connection timeout issue #123
Update documentation for deployment
```

### Branch Naming

* `feature/` - New features (e.g., `feature/add-chat`)
* `fix/` - Bug fixes (e.g., `fix/connection-error`)
* `docs/` - Documentation (e.g., `docs/update-readme`)
* `refactor/` - Code refactoring (e.g., `refactor/webrtc-service`)

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Adding Tests

Please add tests for any new features or bug fixes. Tests should be:
* Clear and descriptive
* Test one thing at a time
* Use meaningful test names

## Documentation

* Update the README.md if needed
* Update inline code comments
* Update the FEATURES.md for new features
* Update the SETUP.md for configuration changes

## Community

* Be respectful and constructive
* Help others in issues and discussions
* Share your knowledge
* Welcome newcomers

## Questions?

Feel free to open an issue with your question or reach out to the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to DeskPro! 🎉

