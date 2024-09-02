{common_vars,host_vars, user,...}:
{config,pkgs,lib, inputs,...}:
let
    functionsModule = (import ../../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
    cfg = if functionsModule.functions.isEditorEnabled user "neovim" then {
            
            enable = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
            defaultEditor = functionsModule.functions.useEditorAsDefaultEditor user "neovim";
        } else {
            enable = false;
        };
in
{
    config =cfg;
}
