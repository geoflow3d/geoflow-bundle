{
  description = "Geoflow build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Use a release that includes Boost 1.69
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.pkg-config
            pkgs.cmakeCurses
          ];
          buildInputs = [
            pkgs.boost175
            pkgs.cgal_5
            pkgs.LAStools
            pkgs.gdal
            pkgs.sqlite
            pkgs.openssl
            pkgs.mpfr
            pkgs.gmp
            pkgs.nlohmann_json
            pkgs.proj
            pkgs.geos
            pkgs.eigen
          ];

          # shellHook = ''
            # export CMAKE_PREFIX_PATH="${pkgs.boost175}:$CMAKE_PREFIX_PATH"
            # export PKG_CONFIG_PATH="${pkgs.boost175}/lib/pkgconfig:$PKG_CONFIG_PATH"
            # export CMAKE_FIND_ROOT_PATH="${pkgs.boost175}"
          #   export CMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH
          #   export CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
          #   export CMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH
          #   export CMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
          #   export CMAKE_SYSTEM_PREFIX_PATH=""
          #   export CMAKE_IGNORE_PATH="/usr/lib:/usr/local/lib:/lib"

          # '';
        };
      });
}
