{common_vars,host_vars, ...}:
{config,lib,pkgs,inputs,flake_file_path,...}:
let
    functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
    enableBoot = !functionsModule.functions.isWsl;
in 
{
    boot.loader= {
        grub = lib.mkIf enableBoot {
            enable = true;
            devices=[config.disko.devices.disk.one.device];
            useOSProber = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
        };
    };
}