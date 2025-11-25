# Python Development Template with `uv` and Nix ❄️🐍

A simple template for setting up Python development environments on NixOS with minimal complexity, focusing on dependency and Python version management. This guide will walk you through configuring the environment for your desired Python version.

---

## 🚀 Getting Started

### Quick Project Creation

1. Use `nix run github:lonerOrz/loneros-nur#uv-nix <projectname>` to quickly create a new project
2. Navigate to your project directory: `cd <projectname>`

---

## 🛠️ Customization Steps

### 1. Set Python Version 🐍 (Optional)

1. Create a `.python-version` file in the project root
2. Set the contents to your desired Python version (e.g., `3.10` or `3.11.5`)

### 2. Configure Dependencies ✏️

1. Open the `pyproject.toml` file
2. Add or modify the `[tool.uv]` section with your required packages:
   ```toml
   [tool.uv]
   dependencies = [
       "requests>=2.28.0",
       "numpy>=1.24.0"
   ]
   ```

### 3. Regenerate Lock File 🔄

1. Run the following command to regenerate the `uv.lock` file:
   ```bash
   nix develop -c uv lock
   ```
   *Note: Nix will complain if this file doesn't exist*

### 4. Enter Development Environment 🌟

1. Activate the development environment with:
   ```bash
   nix develop
   ```
2. Your environment is now configured with your selected Python version and dependencies

---

## 📖 Usage Guide

### Running Python Code
Use `uv run python` to execute the configured Python interpreter.

### Managing Dependencies
- Add packages: `uv add <package>`
- Remove packages: `uv remove <package>`

### Updating Lock File
If you modify `pyproject.toml` directly (without using `uv` commands), run `uv lock` to regenerate the `uv.lock` file.

---

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this template!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
