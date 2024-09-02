{common_vars,host_vars, user,...}:
{config,pkgs,lib, inputs,...}:
let
    functionsModule = (import ../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
    isEnabled = functionsModule.functions.isGnomeEnabled;
    cfg = if isEnabled then {
      gtk = {
        enable = true;
        theme = {
          name= "whitesur-gtk-theme";
          package = pkgs.whitesur-gtk-theme; 

        };
        iconTheme = {
          name = "WhiteSur-dark";
          package = pkgs.whitesur-icon-theme;

        };
        cursorTheme= {
          name="WhiteSur-cursors";
          package = pkgs.whitesur-cursors;
        };
        gtk3.extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=1
          '';
        };

        gtk4.extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=1
          '';
        };
      };
      home.sessionVariables.GTK_THEME="whitesur-gtk-theme";
      dconf.settings = {
          
          "org/gnome/desktop/interface" = {
            gtk-theme = lib.mkForce "WhiteSur-Dark-solid";
            color-scheme = "prefer-dark";
            font-name="JetBrains Mono";
            monospace-font-name="JetBrains Mono";
            document-font-name="JetBrains Mono";
          };

          "org/gnome/desktop/wm/preferences"={
            button-layout="close,minimize,maximize:appmenu";
          };

          "org/gnome/shell"={
            disable-user-extensions = false; 
            enabled-extensions = [
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "trayIconsReloaded@selfmade.pl"
              "Vitals@CoreCoding.com"
              "dash-to-panel@jderose9.github.com"
              "sound-output-device-chooser@kgshank.net"
              "space-bar@luchrioh"
            ];
          };
          
      };
    }else {
    };
in
{
    config =cfg;
}
