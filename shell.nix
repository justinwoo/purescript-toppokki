{ pkgs ? import <nixpkgs> { } }:
let
  easy-ps = import
    (pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "0ad5775c1e80cdd952527db2da969982e39ff592";
      sha256 = "0x53ads5v8zqsk4r1mfpzf5913byifdpv5shnvxpgw634ifyj1kg";
    })
    {
      inherit pkgs;
    };
in
pkgs.mkShell {
  buildInputs = [
    easy-ps.purs
    easy-ps.psc-package
    pkgs.nodejs
    pkgs.nodePackages.pulp
    pkgs.nodePackages.bower
    pkgs.nodePackages.yarn
  ];
}
