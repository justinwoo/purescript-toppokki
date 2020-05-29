# so we can access the `pkgs` and `stdenv` variables
let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/19.09.tar.gz";
  }) {};

  # nix-prefetch-git https://github.com/justinwoo/easy-purescript-nix
  # 2020-03-18
  pursPkgs = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "aa3e608608232f4a009b5c132ae763fdabfb4aba";
    sha256 = "0y6jikncxs9l2zgngbd1775f1zy5s1hdc5rhkyzsyaalcl5cajk8";
  }) {};

in pkgs.stdenv.mkDerivation {
  name = "toppokki";
  buildInputs = with pursPkgs; [
    purs
    spago
    pkgs.nodejs-12_x
  ];
}
