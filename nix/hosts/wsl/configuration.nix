{ config,pkgs,lib,home-manager, nixos-wsl, inputs,flake_file_path, ... }:
let
    common_vars = import (flake_file_path+ "/variables/common.nix");
    host_vars= import ./variables/host.nix;
    functionsModule = (import ( flake_file_path +  "/modules/system/functions.nix") {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });

in
{
    imports = [
        (import (flake_file_path + "/configurations/common/configuration.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/docker-wsl-fix.nix"))
    ];
    wsl={
        #nativeSystemd = true;
        enable = true;
        defaultUser = functionsModule.functions.wlsDefaultUser;
        docker-desktop.enable = false;
        wslConf.automount.root = "/mnt";
        wslConf.interop.appendWindowsPath = false;
        wslConf.network.generateHosts = false;
        
    };
    docker.wsl.fix.enable = true;
    docker.wsl.fix.path= "/mnt/c/Program Files/Docker/Docker/resources";
}