{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{

  options.docker.wsl.fix.path = lib.mkOption {
    default = "/mnt/c/Program Files/Docker/Docker/resources";
    defaultText = "Path to Docker Desktop resources";
    example = "/mnt/c/Program Files/Docker/Docker/resources";
    type = types.str;
  };
  options.docker.wsl.fix.enable = lib.mkEnableOption "docker desktop fix";

  config =
    lib.mkIf (config.docker.wsl.fix.enable) {
      systemd.services.docker-desktop-proxy = {
        script = mkForce ''
          ${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop '${config.docker.wsl.fix.path}'
        '';
        path = [ pkgs.mount ];
      };
    };
}