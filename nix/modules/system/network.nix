{common_vars,host_vars, ...}:
{config,lib,pkgs,inputs,flake_file_path,...}:
let
    functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
    enableNetworking = !functionsModule.functions.isWsl;
in 
{
    networking = lib.mkIf enableNetworking  {
        hostName = host_vars.host.name;
    };
}


