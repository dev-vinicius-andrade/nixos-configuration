{common_vars, host_vars, user, ...}:
{config, pkgs, lib, inputs, ...}:

let
  functionsModule = (import ../../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
  isEnabled = functionsModule.functions.isFirefoxEnabled user;
  cfg = if !isEnabled then 
  {
    enable = false;
  }
  else
  {
     enable = true;
    
  };
in 
{
  config = cfg;
}
