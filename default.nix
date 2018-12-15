{ nixpkgs ? <nixpkgs>
, system ? builtins.currentSystem
}:

let
  makeTest = import "${nixpkgs}/nixos/tests/make-test.nix";

in {
  test = makeTest (import ./test.nix) { inherit system; };
}
