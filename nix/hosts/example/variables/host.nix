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
        ssh = {
            enable = true;
            PermitRootLogin = "yes"; # Optional: allows root login, use with caution
            PasswordAuthentication = true; # Optional: allows password authentication
            forwardX11 = true;
        };
        packages = [
            "zsh"
            "gnumake"
            "eza"
            "direnv"
            "gcc"
            "xclip"
        ];
    };
    users = {
        enable = true;
        homeManager = true;
        users=[{
            username = "user";
            isNormalUser = true;
            initialPassword = "passwd";
            extraGroups = ["wheel" "networkmanager"];
            defaultShell = "zsh";
            dot_files = {
                enable = true;
                git= {
                    url="https://github.com/dev-vinicius-andrade/dotfiles.git";
                    ref="main";
                    commit_id="130febdce65716e4465457400cb6860c6d50a499";
                };
            };
            ignoreShellProgramCheck = true;
            packages = [
                "fzf"
                "git"
                "curl"
                "starship"
                "neovim"
                "zellij"
                "nushell"
                "ripgrep"
                "jq"
                "lazygit"
                "nodejs"
            ];
        }];
    };
    docker= {
        storageDriver=null;
    };
}