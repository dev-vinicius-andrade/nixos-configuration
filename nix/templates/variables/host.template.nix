{
    host = {
        name="nixos";
        ssh = {
            enable = true;
            PermitRootLogin = "yes"; # Optional: allows root login, use with caution
            PasswordAuthentication = true; # Optional: allows password authentication
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
                    #url="git@github.com:dev-vinicius-andrade/dotfiles.git";
                    url="https://github.com/dev-vinicius-andrade/dotfiles.git";
                    ref="main";
                    commit_id="08c46cae3044dd521c5f7f1a26060463f25a25f2";
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