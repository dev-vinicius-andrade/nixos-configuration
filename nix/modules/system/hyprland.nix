
{common_vars,host_vars, ...}:
{ config, lib, pkgs,inputs, ... }:
let

  functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
  isEnabled = functionsModule.functions.isHyprlandEnabled;
  cfg = if isEnabled then {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    };
    services = {
      xserver.videoDrivers = ["nvidia"];
      # exportConfiguration = true;
      displayManager = {
        defaultSession = "hyprland";
        sddm= {
          enable=true;
          wayland = {
            enable = true;
          };
        };
      };
    }; 
    
    environment.sessionVariables.NIXOS_OZONE_WL = "1"; 
  } else {
    programs.hyprland = {
      enable = false;
    };
  };
in
{  
  config = cfg;
}
