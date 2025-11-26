{
  description = "uv2nix devshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      uv2nix,
      pyproject-nix,
      pyproject-build-systems,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = systems;
      perSystem =
        {
          pkgs,
          lib,
          ...
        }:
        let
          workspaceRoot = ./.;
          venvName = "venv";

          # detect python version from .python-version
          python =
            let
              detect =
                version:
                let
                  parts = lib.splitString "." version;
                  majorMinor = lib.concatStringsSep "" (lib.take 2 parts);
                in
                pkgs."python${majorMinor}";
            in
            if builtins.pathExists ./.python-version then
              detect (builtins.head (lib.splitString "\n" (builtins.readFile ./.python-version)))
            else
              pkgs.python312;

          workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = workspaceRoot; };
          overlay = workspace.mkPyprojectOverlay {
            sourcePreference = "wheel";
          };
          baseSet = pkgs.callPackage pyproject-nix.build.packages { inherit python; };
          pythonSet = baseSet.overrideScope (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
            ]
          );
          venv = pythonSet.mkVirtualEnv "${venvName}" workspace.deps.default;
        in
        {

          devShells.default = pkgs.mkShell {
            packages = [
              venv
            ];
          };
        };
    };
}
