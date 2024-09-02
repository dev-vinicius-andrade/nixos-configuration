{common_vars,host_vars, ...}:
{config,lib,pkgs,inputs,flake_file_path,...}:
let
      functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs inputs; });
      secrets= functionsModule.functions.sops.secrets;
in
{
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];
     sops = lib.mkIf host_vars.sops.enable {
        defaultSopsFile =  (flake_file_path+ "${host_vars.sops.secrets_file}" );
        validateSopsFiles = false;
        age = {
            # automatically import host SSH keys as age keys
            sshKeyPaths = host_vars.sops.age.sshKeyPaths;
            keyFile=functionsModule.functions.sops.keyFile;
            generateKey = true;
        };
        secrets= secrets;
    };
}