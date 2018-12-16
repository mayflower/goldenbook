{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
}:
let pkgs = import nixpkgs { inherit system; };
in {
  test = pkgs.nixosTest ./test.nix;
}
