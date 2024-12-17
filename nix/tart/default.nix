{
  # apple-sdk_12, # absent in pkgs-swift
  callPackage,
  pkgs-swift,
  rustPlatform,

  enableSoftnet ? false,
  ...
}:

let
  softnet = callPackage ./softnet.nix { inherit rustPlatform; };

in
pkgs-swift.callPackage ./tart.nix {
  inherit

    # apple-sdk_12
    softnet
    enableSoftnet
    ;
}
