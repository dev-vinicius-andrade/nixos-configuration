{
    sops={
        enable=true;
        secrets_file="/secrets/host/wsl/secrets.yaml";
        age={
            sshKeyPaths=[ "/etc/ssh/ssh_id_ed25519" ];
        };
    };
    host = {
        name="nixos";
        packages = [
            "zsh"
            "gnumake"
            "eza"
            "direnv"
            "gcc"
            "xclip"
            "sops"
            "age"
        ];
        wsl = {
            enable = true;
            defaultUser = "dev-vinicius-andrade";
        };
    };   
    users = {
        enable = true;
        homeManager = true;
        users=[{
            username = "dev-vinicius-andrade";
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager"];
            initialPassword = {
                sops="passwords/users/dev-vinicius-andrade";
            };
            defaultShell = "zsh";
            defaultTerminal="alacritty";
            dot_files = {
                enable = true;
                path = "/mnt/e/repos/github/dev-vinicius-andrade/dotfiles";
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
                #defaultEditor = "nano";
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