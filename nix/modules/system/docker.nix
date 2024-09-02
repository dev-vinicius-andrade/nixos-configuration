{common_vars,host_vars, ...}:
{ config, lib, pkgs,inputs, ... }:
let

  functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
  enableDocker = functionsModule.functions.isPackageEnabled "docker";
  cfg = if enableDocker then
  {
    virtualisation.docker = {
      enable = true;
      storageDriver= host_vars.docker.storageDriver;
    };
  } else {
    
      virtualisation.docker = {
        enable = false;
        enableOnBoot=true;
      };
  };
in
{  
  config = cfg;
}
