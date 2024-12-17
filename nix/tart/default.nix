{
  apple-sdk_12,
  callPackage,
  # lib,
  pkgs-swift,
  src,
  rustPlatform,
  # enableSoftnet ? false,
  ...
}:

let

  softnet = callPackage ./softnet.nix { inherit rustPlatform; };
  inherit (pkgs-swift)
    makeWrapper
    swift
    swiftpm
    swiftpm2nix
    swiftPackages
    ;

  generated = swiftpm2nix.helpers ./generated;
in

swiftPackages.stdenv.mkDerivation {
  pname = "tart";
  version = "2.22.2";

  inherit src;

  buildInputs = [
    apple-sdk_12
    softnet
  ];

  nativeBuildInputs = [
    makeWrapper
    swift
    swiftpm
  ];

  configurePhase = generated.configure;
  installPhase = true;

  buildPhase = ''
    runHook preBuild
    swift build -c release
    runHook postBuild
  '';

  # installPhase = ''
  #   runHook preInstall

  #   # ./tart.app/Contents/MacOS/tart binary is required to be used in order to
  #   # trick macOS to pick tart.app/Contents/embedded.provision profile for elevated
  #   # privileges that Tart needs
  #   mkdir -p $out/bin $out/Applications
  #   cp -r tart.app $out/Applications/tart.app
  #   makeWrapper $out/Applications/tart.app/Contents/MacOS/tart $out/bin/tart \
  #     --prefix PATH : ${lib.makeBinPath (lib.optional enableSoftnet softnet)}
  #   install -Dm444 LICENSE $out/share/tart/LICENSE

  #       runHook preInstall
  #       install -Dm755 .build/${stdenv.hostPlatform.darwinArch}-apple-macosx/release/${pname} -t $out/bin
  #       runHook postInstall
  #     '';

}
