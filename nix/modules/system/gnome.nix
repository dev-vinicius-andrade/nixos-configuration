{common_vars,host_vars, ...}:
{config,lib,pkgs,inputs,flake_file_path,...}:
let
    functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
    cfg = {
      services.xserver.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      environment.gnome.excludePackages = (with pkgs; [
          # for packages that are pkgs.*
          gnome-tour
          gnome-connections
          epiphany # web browser
          geary # email reader
          evince # document viewer
          gnome-photos
          gedit #text editor
          gnome-console
          cheese
          gnome-terminal
      ]) ++ (with pkgs.gnome; [
          # for packages that are pkgs.gnome.*
          gnome-music
          tali
          hitori
          atomix
          gnome-initial-setup
          gnome-contacts

      ]);
      services.gnome = {
        games.enable = false;
        core-developer-tools.enable = true;
      };
      programs.dconf={
       enable=true;
      };
    };
    
in
{
  config = cfg;
}
