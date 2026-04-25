{
  description = "MikanOS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      llvm = pkgs.llvmPackages_14;
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          gnumake
          nasm
          qemu
          acpica-tools
          unzip
          curl
          wget
          python3
          mtools

          llvm.clang-unwrapped
          llvm.lld
          llvm.llvm
        ];
      };
    });
}
