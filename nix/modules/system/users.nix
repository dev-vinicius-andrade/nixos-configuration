{common_vars,host_vars, ...}: {config, lib, pkgs, home-manager,inputs, ...}@args:
let
  functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
  userConfigs = map functionsModule.functions.createUserConfig host_vars.users.users;
  homeManagerConfigs = map (user: functionsModule.functions.createHomeManagerConfig user common_vars.nix.version) host_vars.users.users;
  #passwordsSecrets= lib.mkMerge [functionsModule.functions.sops.passwordsSecrets];
  secrets= functionsModule.functions.sops.secrets;
in
{
  imports=[];
  options = {
  };
  config = lib.mkIf host_vars.users.enable {
    sops.secrets = secrets;
    users.mutableUsers=false;
    users.users = lib.mkMerge userConfigs;
    home-manager = lib.mkIf host_vars.users.homeManager (lib.mkMerge homeManagerConfigs);
  };
}