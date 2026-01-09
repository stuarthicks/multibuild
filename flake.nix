{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # Build executables. See https://nixos.org/manual/nixpkgs/stable/#sec-language-go
      packages = eachSystem (pkgs: {
        default = pkgs.buildGoModule {
          pname = "multibuild";
          version = builtins.substring 0 8 (self.lastModifiedDate or "19700101");
          src = self.outPath;
          vendorHash = null;
          meta = { };
          doCheck = false; # TODO: this disables the integration test which fails in nix due to tmpdir shenanigans
        };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.go
            pkgs.gopls
          ];
        };
      });

    };
}
