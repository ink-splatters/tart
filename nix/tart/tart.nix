{
  # apple-sdk,
  swift,
  swiftpm,
  swiftpm2nix,
  swiftPackages,
  tart,

  enableSoftnet ? false,
  softnet,
  src,
  ...
}:

let

  generated = swiftpm2nix.helpers ./generated;
  inherit (swiftPackages) stdenv;

  stdenvNoCC = stdenv; # dirty hack

  pname = "tart";
  version = "2.22.2";
in

(tart.override {
  inherit
    stdenvNoCC
    enableSoftnet
    softnet
    ;
}).overrideAttrs
  (_oa: {
    inherit pname version src;

    # buildInputs = [ apple-sdk ];

    nativeBuildInputs = _oa.nativeBuildInputs ++ [
      swift
      swiftpm
    ];

    configurePhase = generated.configure;

    installPhase = ''
      runHook preInstall
      install -Dm755 .build/${stdenv.hostPlatform.darwinArch}-apple-macosx/release/${pname} -t $out/bin
      runHook postInstall
    '';

  })
