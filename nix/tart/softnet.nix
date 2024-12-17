{
  llvmPackages_19,
  apple-sdk_12,
  lib,
  fetchFromGitHub,
  rustPlatform,
  ...
}:
let
  inherit (llvmPackages_19) clang bintools stdenv;
  target-triplet =
    let
      inherit (stdenv.hostPlatform) config;
    in
    config;
in
rustPlatform.buildRustPackage rec {
  pname = "softnet";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "cirruslabs";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-ekpqg9TsSKfk8reU0iIArKoEb/uDZl8HkwzBBU7zRWw=";
  };

  cargoLock = {
    lockFile = src + "/Cargo.lock";
  };

  sandboxProfile = ''
    (allow process-exec
      (literal "/usr/bin/install")
      (with no-sandbox))
  '';
  installPhase = ''
    		mkdir -p $out/bin
        install -D target/${target-triplet}/release/${pname} -t $out/bin
  '';

  buildInputs = [
    apple-sdk_12
    bintools
  ];

  nativeBuildInputs = [
    clang
    bintools
  ];

  env.RUSTFLAGS = lib.concatMapStringsSep " " (x: "-C ${x}") [
    "target-cpu=apple-m1"
    "codegen-units=1"
    "embed-bitcode=yes"
    "linker=${clang}/bin/cc"
    "link-args=-fuse-ld=lld"
    "lto=thin"
    "opt-level=3"

  ];

  # cargoBuildFlags = [ "--verbose" ];

  meta = {
    description = "Software networking with isolation for Tart";
    homepage = "https://github.com/${src.owner}/${pname}";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.darwin;
    mainProgram = "${pname}";
  };
}
