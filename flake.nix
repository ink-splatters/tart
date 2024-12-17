{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";
    flake-utils.inputs.systems.follows = "systems";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
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
    sandbox = "relaxed";
  };

  outputs =
    {
      fenix,
      flake-utils,
      nixpkgs,
      git-hooks,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

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
          default = callPackage ./nix/dev-shell.nix { inherit pre-commit-check; }; # rustPlatform; };
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
          inherit rustPlatform src;
          enableSoftnet = true;
        };
      }
    );
}
