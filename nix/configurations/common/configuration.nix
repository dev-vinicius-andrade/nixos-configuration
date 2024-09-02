{common_vars,host_vars}:{ config,pkgs,lib,home-manager, inputs,flake_file_path, ... }@args:
let
    functionsModule = (import ( flake_file_path +  "/modules/system/functions.nix") {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
in
{
    # Enable Flakes and Nix Command
    nix.settings.experimental-features = ["nix-command" "flakes"];
    imports = [
        (import (flake_file_path + "/modules/system/packages/common.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/sops.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/boot.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/network.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/users.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/fonts.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/docker.nix") {common_vars = common_vars; host_vars=host_vars;})
    ];
    time.timeZone = common_vars.timeZone;
    services.kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {name = "JetBrainsMono"; package=pkgs.jetbrains-mono;}
      ];
      extraConfig = ''
        xkb-layout=br
        xkb-variant=abnt2
      '';
    };
    console.keyMap = common_vars.keyMap;
    console.font = common_vars.font;
    system.stateVersion = common_vars.nix.version;
        system.activationScripts.setupSshDirs = {
        text = functionsModule.functions.createSshActivationScript host_vars.users.users;
    };
}
