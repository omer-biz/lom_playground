{
  description = "Hermes playground";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        cmake
        nodejs_20
        elmPackages.elm
      ];

      shellHook = ''
        echo "Dev shell ready"
      '';
    };
  };
}
