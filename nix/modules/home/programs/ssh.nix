{common_vars,host_vars, user,...}:
{config,pkgs,lib, inputs,...}:
let
    functionsModule = (import ../../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
    cfg = if user.ssh.enable then {
            enable = true;
            matchBlocks= 
                if !(builtins.hasAttr "ssh" user) then
                    {}
                else if !(builtins.hasAttr "matchBlocks" user.ssh) then
                    {}
                else
                    user.ssh.matchBlocks;
        } else {
            enable = false;
        };
in
{
    config =cfg;
}
