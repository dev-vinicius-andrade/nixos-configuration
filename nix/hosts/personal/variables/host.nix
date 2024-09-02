{
    sops={
        enable=true;
        secrets_file="/secrets/host/personal/secrets.yaml";
        age={
            sshKeyPaths=[ "/etc/ssh/ssh_id_ed25519" ];
        };
    };
    host = {
        name="personal-nixos";
        packages = [
            "zsh"
            "gnumake"
            "eza"
            "direnv"
            "gcc"
            "xclip"
            "sops"
            "age"
            "gnome-tweaks"
            "whitesur-gtk-theme"
            "whitesur-cursors"
            "whitesur-icon-theme"
        ];
        gnomePackages=[
        ];
        gnomeExtensionsPackages= [
          "user-themes"
          "tray-icons-reloaded"
          "vitals"
          "dash-to-panel"
          "sound-output-device-chooser"
          "space-bar"
        ];

        wsl = {
            enable = false;
        };
        hyprland = {
          enable = false;
        };
        gnome={
          enable=true;
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
            defaultTerminal="alacritty";
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
                "docker"
                "google-chrome"
                "alacritty"
                "go"
                "tinygo"
                "rustup"
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
                    {name="ssh_rsa"; fileName="id_rsa"; private_key="private_keys/ssh_rsa"; public_key="public_keys/ssh_rsa";}
                ];
                matchBlocks={
                    "github.com"={
                        hostname="github.com";
                        identityFile="~/.ssh/ssh_id_ed25519";
                    };
                    "hiperstream.visualstudio.com"={
                        hostname="hiperstream.visualstudio.com";
                        identityFile="~/.ssh/ssh_rsa";
                    };
                };
            };
            firefox = {
              enable = false;
            };
            chromium = {
              enable = false;
              extensions = [{
                description = "Nord Pass";
                id= "eiaeiblijfjekdanodkjadfinkhbfgcd";
              }];
            };
            hyprland = {
              config= {
                path = "~/dotfiles/hyprland/hyprland.conf";
              };
              waybar= {
                config = {
                  folder = "~/dotfiles/hyprland/waybar";
                };
              };
              
            };

        }];
    };
    docker= {
        storageDriver=null;
    };
}
