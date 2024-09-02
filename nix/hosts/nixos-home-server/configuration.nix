{ config,pkgs,lib,home-manager, inputs,flake_file_path, ... }:
let
    common_vars = import ./variables/common.nix;
    host_vars= import ./variables/host.nix;
    functionsModule = (import ( flake_file_path +  "/modules/system/functions.nix") {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });

in
{
    imports = [
        (import (flake_file_path + "/configurations/common/configuration.nix") {common_vars = common_vars; host_vars=host_vars;})
    ];
    services.openssh=  lib.mkIf host_vars.host.ssh.enable {
        enable = true;
        settings = {
            PermitRootLogin = host_vars.host.ssh.PermitRootLogin;
            PasswordAuthentication = host_vars.host.ssh.PasswordAuthentication;
            X11Forwarding = host_vars.host.ssh.forwardX11;
        };
    };
    programs.ssh.forwardX11= lib.mkIf host_vars.host.ssh.enable host_vars.host.ssh.forwardX11;
    
}