{ config,pkgs,lib,home-manager, nixos-wsl, inputs,flake_file_path, ... }:
let
    common_vars = import (flake_file_path+ "/variables/common.nix");
    host_vars= import ./variables/host.nix;
    functionsModule = (import ( flake_file_path +  "/modules/system/functions.nix") {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
in
{
    imports = [
        (import (flake_file_path + "/configurations/common/configuration.nix") {common_vars = common_vars; host_vars=host_vars;})
        (import (flake_file_path + "/modules/system/gnome.nix") {common_vars = common_vars; host_vars=host_vars;})

    ];
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable=true;
    };
    nixpkgs.config.allowUnfree = true;
    # programs.hyprland = {
    #   enable = true;
    #   xwayland.enable = true;
    # };
    environment.sessionVariables = {

      # NIXOS_OZONE_WL = "1";
    };
    boot.kernelParams =  [ 
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1" 
      "usbcore.autosuspend=-1" 
      "nvidia-drm.fbdev=1"
      "NVreg_EnableGpuFirmware=0"
    ];

    hardware = {
      graphics.enable = true;
      pulseaudio.enable=false;
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
    };
    services.openssh=  lib.mkIf host_vars.host.ssh.enable {
        enable = true;
        settings = {
            PermitRootLogin = host_vars.host.ssh.PermitRootLogin;
            PasswordAuthentication = host_vars.host.ssh.PasswordAuthentication;
            X11Forwarding = host_vars.host.ssh.forwardX11;
        };
    };
}

