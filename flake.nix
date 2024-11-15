{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [ elixir_1_17 ];
            env = { ERL_AFLAGS = "-kernel shell_history enabled"; };
          };
        }
    );
}
