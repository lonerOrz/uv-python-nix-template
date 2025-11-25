{ pkgs, ... }:

pkgs.writeShellScriptBin "mkproject" ''
    set -euo pipefail

    if [ -z "''${1-}" ]; then
      echo "Usage: mkproject <project-name>"
      exit 1
    fi

    name="$1"

    echo "📦 Creating project: $name"

    nix run nixpkgs#git -- clone https://github.com/lonerOrz/uv-python-nix-template.git "$name"

    cd "$name"

    rm -rf .git
    nix run nixpkgs#git -- init
    nix run nixpkgs#git -- add .

    echo "▶ Creating pyproject.toml ..."
    cat > pyproject.toml <<EOF
  [project]
  name = "$name"
  version = "0.1.0"
  requires-python = ">=3.12"

  [build-system]
  requires = ["hatchling"]
  build-backend = "hatchling.build"
  EOF

    if command -v direnv >/dev/null 2>&1; then
      echo "▶ Creating .envrc"
      cat > .envrc <<EOF
  use flake
  EOF
      direnv allow .
    else
      echo "⚠️ No direnv — skipping .envrc"
    fi

    echo "▶ Running uv lock ..."
    nix develop -c "uv lock" || true

    echo "🎉 Project '$name' created!"
''
