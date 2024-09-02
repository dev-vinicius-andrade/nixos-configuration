{common_vars, host_vars, user, ...}:
{config, pkgs, lib, inputs, ...}:

let
  functionsModule = (import ../../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
  isEnabled = functionsModule.functions.isChromiumEnabled user;
  extensionIds = map (extension: extension.id) user.chromium.extensions;
  cfg = if !isEnabled then 
  {
    enable = false;
  }
  else
  {
     enable = true;
     commandLineArgs = [
       "--enable-features=UseOzonePlatform" 
       "--ozone-platform=wayland"
       "--oauth2-client-id=77185425430.apps.googleusercontent.com"
       "--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT"
     ];
     extensions = [
      
     ] ++ extensionIds;
    
  };
in
{
  config = cfg;
}
