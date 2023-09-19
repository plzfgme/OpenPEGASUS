{
  description = "C/C++ development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux"
    "i686-linux"
    "aarch64-linux"
    "x86_64-darwin"
  ]
    (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        stdenv = pkgs.gcc13Stdenv;
      in
      {
        devShells.default = (pkgs.mkShell.override { inherit stdenv; }) {
          hardeningDisable = [ "all" ];

          packages = with pkgs; [
            autoconf
            automake
            pkg-config
            cmake
            bear
            clang-tools_16

            gmp
          ];

          # Important if you want to use `-march=native`
          shellHook = ''
            export NIX_ENFORCE_NO_NATIVE=0
          '';
        };
      });
}
