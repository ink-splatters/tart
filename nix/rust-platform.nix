{
  pkgs,
  fenix,
  system,
  ...
}:
let
  toolchain =
    let
      inherit (fenix.packages.${system}.minimal) toolchain;
    in
    toolchain.overrideAttrs (_oa: {
      propagatedSandboxProfile = ''
        ; Allow the system OpenSSL to read its config on 14.2+.
        ; discussed here: https://github.com/NixOS/nix/issues/9625#issuecomment-1863545248
        (allow file-read* (literal "/private/etc/ssl/openssl.cnf"))
      '';
    });
in
pkgs.makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}
