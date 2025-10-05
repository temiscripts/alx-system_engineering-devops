# Contributing to Shell Variables & Expansions Project

First off, thank you for considering contributing to this project! 🎉

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include your environment details** (OS, shell version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repository
2. Create a new branch from `main`
3. Make your changes
4. Add tests for your changes (if applicable)
5. Ensure all tests pass
6. Update documentation as needed
7. Submit a pull request

## Development Guidelines

### Shell Script Standards

- **Shebang**: All scripts must start with `#!/bin/bash`
- **Line Count**: All executable scripts must be exactly 2 lines long
- **Permissions**: All scripts must be executable (`chmod +x`)
- **Newlines**: All files must end with a newline character
- **Forbidden**: Don't use `&&`, `||`, `;`, `bc`, `sed`, or `awk`

### Code Style

- Use meaningful variable names
- Follow POSIX shell scripting conventions where possible
- Comment your code when necessary
- Keep scripts simple and focused on one task

### Testing

- Test your scripts on Ubuntu 20.04 LTS
- Ensure scripts work with the expected input/output
- Run the provided test suite: `./test_all.sh`
- Verify line count: `wc -l script_name`

### Documentation

- Update README.md if you add new files
- Include usage examples for new scripts
- Document any environment variables required
- Update the file description table

## Project Structure

```bash
0x03-shell_variables_expansions/
├── README.md              # Project documentation
├── LICENSE               # License file
├── .gitignore           # Git ignore rules
├── CONTRIBUTING.md      # This file
├── test_all.sh         # Comprehensive test script
├── 0-alias             # Task 0 script
├── 1-hello_you         # Task 1 script
├── ...                 # Other task scripts
└── 13-print_float      # Task 13 script
```

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/alx-system_engineering-devops.git
   cd alx-system_engineering-devops/0x03-shell_variables_expansions
   ```

2. **Make scripts executable:**

   ```bash
   chmod +x *
   ```

3. **Run tests:**

   ```bash
   ./test_all.sh
   ```

## Commit Message Guidelines

Use clear and meaningful commit messages:

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Examples

```bash
Add binary to decimal conversion script

Fix PATH counting algorithm in 3-paths
- Handle empty PATH components
- Improve error handling

Update README with comprehensive documentation
- Add installation instructions
- Include troubleshooting section
- Add contributing guidelines
```

## Issue and Pull Request Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `question` - Further information is requested

## Questions?

Don't hesitate to ask questions by opening an issue with the `question` label.

## Recognition

Contributors will be recognized in the project documentation and/or commit history.

Thank you for contributing! 🚀
