{common_vars,host_vars, user,...}:
{config,pkgs,lib, inputs,...}:
let
    functionsModule = (import ../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
    isEnabled = functionsModule.functions.isHyprlandEnabled;
    startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
      ${pkgs.waybar}/bin/waybar &
      ${pkgs.swww}/bin/swww init &

      sleep 1
        "plugin:borders-plus-plus" =       # enable = true;

    '';

    cfg = if isEnabled then {

      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      plugins = [
        inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars

      ];
      settings = {
        exec-once = [
        ''${startupScript}/bin/start''
        ];
        cursor = {
            no_hardware_cursors = true;
        };
        env = [
          "GLX_VENDOR_LIBRARY_NAME,nvidia"
          "GL_VRR_ALLOWED, 1"
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "XDG_SESSION_TYPE,wayland"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "ELECTRON_OZON_PLATFORM_HINT,auto"
        ];
        source = [
          "${user.hyprland.config.path}"
        ];
      };
    }else {
      enable = false;
    };
in
{
    config =cfg;
}
