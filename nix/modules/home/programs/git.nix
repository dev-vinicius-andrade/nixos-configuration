{common_vars,host_vars, user,...}:
{config,pkgs,lib, inputs,...}:
let
    functionsModule = (import ../../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
    cfg = if (builtins.hasAttr "git" user) then {
        enable = true;
        userName = if (builtins.hasAttr "userName" user.git) then user.git.userName else user.username;
        userEmail = if (builtins.hasAttr "userEmail" user.git) then user.git.userEmail else "${user.userName}@${host_vars.host.name}.local";
    } else {
            enable = false;
    };
in
{
    config =cfg;
}
