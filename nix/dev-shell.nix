{
  mkShell,
  pre-commit-check,
  # rustPlatform,
  swift,
  swiftpm,
  swiftpm2nix,
  swiftPackages,
  ...
}:

let
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
