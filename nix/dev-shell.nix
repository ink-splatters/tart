{
  mkShell,
  pkgs-swift,
  pre-commit-check,
  # rustPlatform,
  ...
}:

let

  inherit (pkgs-swift)
    swift
    swiftpm
    swiftpm2nix
    swiftPackages
    ;

  inherit (swiftPackages) stdenv;
in
# inherit (rustPlatform) cargo rustc;
mkShell.override { inherit stdenv; } {
  nativeBuildInputs = [
    swift
    swiftpm
    swiftpm2nix
    # cargo
    # rustc
  ];

  inherit (pre-commit-check) shellHook;
}
