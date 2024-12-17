{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    # pinned to version containing binary-cached swift and swiftpm
    nixpkgs-swift.url = "github:NixOS/nixpkgs/b69de56fac8c2b6f8fd27f2eca01dcda8e0a4221";

    systems.url = "github:nix-systems/default";
    flake-utils.inputs.systems.follows = "systems";

    git-hooks = {
      url = "github:ink-splatters/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://aarch64-darwin.cachix.org" # pre-built swift and swiftpm
    ];
    extra-trusted-public-keys = [
      "aarch64-darwin.cachix.org-1:mEz8A1jcJveehs/ZbZUEjXZ65Aukk9bg2kmb0zL9XDA="
    ];
    # sandbox = "relaxed";
  };

  outputs =
    {
      fenix,
      flake-utils,
      nixpkgs,
      nixpkgs-swift,
      git-hooks,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-swift = import nixpkgs-swift {
          inherit system;
          config.allowUnfree = true;
        };

        inherit (pkgs)
          callPackage
          mkShell
          stdenvNoCC
          nixfmt-rfc-style
          ;

        pre-commit-check = callPackage ./nix/pre-commit-check.nix { inherit git-hooks system src; };
        rustPlatform = callPackage ./nix/rust-platform.nix { inherit fenix system; };
        src = ./.;
      in
      {

        checks = {
          inherit pre-commit-check;
        };

        devShells = {
          default = callPackage ./nix/dev-shell.nix { inherit pre-commit-check pkgs-swift; }; # rustPlatform; };
          install-hooks = mkShell.override { stdenv = stdenvNoCC; } {
            inherit system;
            shellHook = ''
              ${pre-commit-check.shellHook}
              echo Done!
              exit
            '';
          };
        };

        formatter = nixfmt-rfc-style;

        packages.default = callPackage ./nix/tart {
          inherit pkgs-swift src rustPlatform;
          enableSoftnet = true;
        };

      }
    );
}
