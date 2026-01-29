{
  description = "Catch fish in Terraria legally and automatically!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    defaultSystems = ["aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux"];

    forAllSystems = f:
      nixpkgs.lib.genAttrs defaultSystems (system:
        f system (import nixpkgs {
          inherit system;
          overlays = self.overlays;
        }));
  in {
    overlays = [
      (
        final: prev: rec {
          # https://github.com/NixOS/nixpkgs/blob/c339c066b893e5683830ba870b1ccd3bbea88ece/nixos/modules/programs/nix-ld.nix#L44
          # > We currently take all libraries from systemd and nix as the default.
          pythonldlibpath = with prev;
            lib.makeLibraryPath [
              # for python:
              acl
              attr
              bzip2
              curl
              libsodium
              libssh
              libxml2
              openssl
              stdenv.cc.cc
              systemd
              util-linux
              xz
              zlib
              zstd
              # for PyQT6/PySide6:
              dbus
              fontconfig
              freetype
              glib
              libGL
              libxkbcommon
              xorg.libX11
              python311Full # for python-evdev
              linux
              krb5
              brotli
            ];
          # here we are overriding python program to add LD_LIBRARY_PATH to it's env
          python-ld = prev.stdenv.mkDerivation {
            name = "python";
            buildInputs = [prev.makeWrapper];
            src = prev.python311Full.withPackages (ps: [ps.pyinstaller]);
            installPhase = ''
              mkdir -p $out/bin
              cp -r $src/* $out/
              wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${pythonldlibpath}
              wrapProgram $out/bin/python3.11 --set LD_LIBRARY_PATH ${pythonldlibpath}
            '';
          };
          poetry-ld = prev.stdenv.mkDerivation {
            name = "poetry";
            buildInputs = [prev.makeWrapper];
            src = prev.poetry;
            installPhase = ''
              mkdir -p $out/bin
              cp -r $src/* $out/
              wrapProgram $out/bin/poetry --set LD_LIBRARY_PATH ${pythonldlibpath}
            '';
          };
        }
      )
    ];

    devShells = forAllSystems (
      system: pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            python-ld
            poetry-ld
          ];

          shell = "${pkgs.bash}/bin/bash";
        };

        fhs = let
          base = pkgs.appimageTools.defaultFhsEnvArgs;

          fhs =
            pkgs.buildFHSEnv
            (base
              // {
                name = "FHS";
                targetPkgs = pkgs: (with pkgs; [
                  # for python:
                  acl
                  attr
                  bzip2
                  curl
                  libsodium
                  libssh
                  libxml2
                  openssl
                  stdenv.cc.cc
                  systemd
                  util-linux
                  xz
                  zlib
                  zstd
                  # for PyQT6/PySide6:
                  dbus
                  fontconfig
                  freetype
                  glib
                  libGL
                  libxkbcommon
                  xorg.libX11

                  python311Full
                  linux
                ]);
                runScript = "bash";
                extraOutputsToInstall = ["dev"];
              });
        in
          fhs.env;
      }
    );
  };
}
