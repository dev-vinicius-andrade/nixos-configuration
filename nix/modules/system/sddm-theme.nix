{common_vars,host_vars, ...}:
{config,lib,pkgs,inputs,flake_file_path,...}:
let
    functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
    enableNetworking = !functionsModule.functions.isWsl;
in
pkgs.stdenv.mkDerivation {
  name="sddm-theme";
  src= {};
  installPhase= ''
    mkdir -p $out
    copy -R ./* $out/
  '';
}
