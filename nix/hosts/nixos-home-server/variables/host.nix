{
    sops={
        enable=true;
        secrets_file="/secrets/host/wsl/secrets.yaml";
        age={
            sshKeyPaths=[ "/etc/ssh/ssh_id_ed25519" ];
        };
    };
    host = {
        name="nixos-home-server";
        packages = [
            "zsh"
            "gnumake"
            "eza"
            "direnv"
            "gcc"
            "xclip"
            "sops"
            "age"
            "docker"
        ];
        wsl = {
            enable = false;
        };
        ssh = {
            enable = true;
            PermitRootLogin = "yes"; # Optional: allows root login, use with caution
            PasswordAuthentication = true; # Optional: allows password authentication
            forwardX11 = true;
        };
    };   
    users = {
        enable = true;
        homeManager = true;
        users=[{
            username = "dev-vinicius-andrade";
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager" "docker"];
            initialPassword = {
                sops="passwords/users/dev-vinicius-andrade";
            };
            defaultShell = "zsh";
            dot_files = {
                enable = true;
                git= {
                    ref="main";
                    commit_id="08b227c15bc29ccfc191d79fc089b160aa759743";
                    ssh= {
                        enable=true;
                        url="git@github.com:dev-vinicius-andrade/dotfiles.git";
                       
                    };
                    https={
                        enable=false;
                        url="https://github.com/dev-vinicius-andrade/dotfiles.git";
                    };
                };
            };
            ignoreShellProgramCheck = true;
            packages = [
                "fzf"
                "git"
                "curl"
                "starship"
                "zellij"
                "nushell"
                "ripgrep"
                "jq"
                "lazygit"
                "nodejs"
            ];
            editors= {
                enable = true;
                neovim = {
                     enable = true;
                };
            };
            git={
                userName="Vinicius Andrade";
                userEmail="developer.vinicius.andrade@gmail.com";
            };
            ssh={
                enable=true;
                keys=[
                    {name="ssh"; fileName="ssh_id_ed25519"; private_key="private_keys/ssh"; public_key="public_keys/ssh";}
                ];
                matchBlocks={
                    "github.com"={
                        hostname="github.com";
                        identityFile="~/.ssh/ssh_id_ed25519";
                    };
                };
            };
        }];
    };
    docker= {
        storageDriver=null;
    };
}