{common_vars,host_vars, ...}@custom:
{config, lib, pkgs, inputs, ...}@args:
let
 
 functions = rec {
        clearLog = user: ''
            debug_log="/home/${user.username}/debug.log"
            if [ -f "$debug_log" ]; then
                > "$debug_log"
            else
                touch "$debug_log"
            fi
        '';

        logDebug = msg: user: ''
            debug_log="/home/${user.username}/debug.log"
            echo "${msg}" >> "$debug_log"
        '';
        containsPackage = package: packages: lib.elem package packages;
        # Check if package is in system packages
        packageInSystemPackages = package: functions.containsPackage package host_vars.host.packages;

        # Check if package is in any user packages
        packageInUserPackages = package:  if host_vars.users == null ||  !host_vars.users.enable || !host_vars.users.homeManager then false else   lib.any (user: containsPackage package user.packages) host_vars.users.users;

        # Check if package is enabled in system packages or any user packages
        isPackageEnabled = package: (functions.packageInSystemPackages package)  || (functions.packageInUserPackages package);
        isHyprlandEnabled =  if (builtins.hasAttr "hyprland" host_vars.host) && (builtins.hasAttr "enable" host_vars.host.hyprland) && (host_vars.host.hyprland.enable == true) then true else false; 
        isGnomeEnabled =  if (builtins.hasAttr "gnome" host_vars.host) && (builtins.hasAttr "enable" host_vars.host.gnome) && (host_vars.host.gnome.enable == true) then true else false; 
        copyFiles = src: dest: ''
            mkdir -p ${dest}
            cp -r ${src}/* ${dest}
        '';
        isWsl = if !builtins.hasAttr "wsl" host_vars.host then 
            false
        else if host_vars.host.wsl == null then
            false
        else if !builtins.hasAttr "enable" host_vars.host.wsl then
            false
        else
            host_vars.host.wsl.enable;
        
        wlsDefaultUser = if !functions.isWsl then 
            null
        else if !builtins.hasAttr "defaultUser" host_vars.host.wsl then
            "nixos"
        else if host_vars.host.wsl.defaultUser == null then
            "nixos"
        else if host_vars.host.wsl.defaultUser == "" then
            "nixos"
        else
            host_vars.host.wsl.defaultUser;

        handleIsWslGetInfo= user: ''
            export IS_WSL=true
            ${functions.logDebug "WSL detected" user}
            PATH=$PATH:/mnt/c/Windows/System32:/mnt/c/Windows:/bin
            if command -v cmd.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
                HOST_WIN_HOME=$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d "\r")
                export HOST_HOME=$(wslpath "$HOST_WIN_HOME")
                 ${functions.logDebug "HOST_WIN_HOME=$HOST_WIN_HOME, HOST_HOME=$HOST_HOME" user}
            else
                 ${functions.logDebug "cmd.exe or wslpath not found" user}
                exit 127
            fi
        '';
        handleNotWslGetInfo = user: ''
            export IS_WSL=false
            export HOST_HOME=$HOME
            ${functions.logDebug "Not WSL. HOST_HOME=$HOME" user}
        '';
        getWslInfo = user: ''
        ${functions.logDebug "Checking if WSL..." user}
            if grep -qi "microsoft\\|wsl" /proc/version; then
                ${functions.handleIsWslGetInfo user}
            else
                ${functions.handleNotWslGetInfo user}
            fi
        '';
        
        
        sops={
            keyDir="/var/lib/sops-nix";
            keyFile="${functions.sops.keyDir}/keys.txt";
            userKeyDir= user: "/home/${user.username}/.config/sops/age";
            userKeyFile= user: "${functions.sops.userKeyDir user}/keys.txt";
            createSopsPasswordSecret = user: {
                "passwords/users/${user.username}" = {
                    neededForUsers = true;
                };
            };
            createSopsChromiumSecret = user: {
              "chromium/api_key"={
                    owner = user.username;
                    mode="777";
                    path = "/home/${user.username}/.chromium/api_key";
              };
              "chromium/client_id"={
                    owner = user.username;
                    mode="777";
                    path = "/home/${user.username}/.chromium/client_id";
                };
              "chromium/client_secret"={
                    owner = user.username;
                    mode="777";
                    path = "/home/${user.username}/.chromium/client_secret";
                };
            };
            createSopsPrivateKeySecret = user: key: {
                "${key.private_key}"={
                    owner = user.username;
                    mode="600";
                    path = "/home/${user.username}/.ssh/${key.fileName}";
                };
            };

            createSopsPublicKeySecret = user: key: {
                "${key.public_key}"={
                    owner = user.username;
                    mode="644";
                    path = "/home/${user.username}/.ssh/${key.fileName}.pub";
                };
            };
            userContainsSshKeysConfig = user:
                builtins.hasAttr "ssh" user &&
                builtins.hasAttr "keys" user.ssh &&
                user.ssh.keys != null;
            userContainsPrivateKeysConfig= user: builtins.hasAttr "ssh" user && builtins.hasAttr "privateKeys" user.ssh;
            userContainsPublicKeysConfig= user: builtins.hasAttr "ssh" user && builtins.hasAttr "publicKeys" user.ssh;
            shouldConfigureSshKeys= user:
                user.ssh.enable;
            createUserSshKeysSecrets = user:
               let
                    sshKeys = if functions.sops.userContainsSshKeysConfig user then user.ssh.keys else [];
                in
                    lib.mkMerge
                    (map (key: 
                        let
                        privateKeySecret = functions.sops.createSopsPrivateKeySecret user key;
                        publicKeySecret = functions.sops.createSopsPublicKeySecret user key;
                        in
                        privateKeySecret // publicKeySecret
                    ) sshKeys);
            createSshKeySecrets= users: lib.mkMerge (map functions.sops.createUserSshKeysSecrets users);

            setSopsSecretOwner= user: secret: {
                "${secret}" = {
                    owner = user.username;
                    inherit (config.users.users."${user.username}") group;
                };
            };

            createSopsPasswordSecrets = users: lib.mkMerge (map functions.sops.createSopsPasswordSecret users);
            passwordsSecrets = functions.sops.createSopsPasswordSecrets host_vars.users.users;
            sshSecrets= functions.sops.createSshKeySecrets host_vars.users.users; 
            createSopsChromiumSecrets = users: lib.mkMerge (map functions.sops.createSopsChromiumSecret users);
            chromiumSecrets= functions.sops.createSopsChromiumSecrets host_vars.users.users; 
            secrets = lib.mkMerge [functions.sops.passwordsSecrets functions.sops.sshSecrets functions.sops.chromiumSecrets];
            createSopsKeyDiretory= user: if host_vars.sops.enable then ''
                echo "Creating sops key directory" >> /home/${user.username}/debug.log
                SOPS_KEY_DIR=$(dirname ${functions.sops.userKeyFile user})
                echo "SOPS_KEY_DIR=$SOPS_KEY_DIR" >> /home/${user.username}/debug.log
                mkdir -p "$SOPS_KEY_DIR"
                ${functions.giveOwnership user "$SOPS_KEY_DIR" }
            '' else '''';

            copyKeyFileToUser = user: if host_vars.sops.enable then ''
                ${functions.sops.createSopsKeyDiretory user}
                ${functions.copyFiles functions.sops.keyDir "${functions.sops.userKeyDir user}"}
                ${functions.giveOwnership user "${functions.sops.userKeyDir user}"}
            '' else '''';
            

        };
        hasSshConfig = user:
            if user==null then
                false
            else if !builtins.hasAttr "ssh" user || user.ssh == null then
                false
            else
                true;

        isGetDotFilesByPath = user:
            if user==null then
                false
            else if !builtins.hasAttr "dot_files" user || !user.dot_files.enable then
                false
            else if builtins.hasAttr "path" user.dot_files && user.dot_files.path != null && user.dot_files.path != "" then
                true
            else
                false;
        getDotFiles = user:
            if user==null then
                null
            else if !builtins.hasAttr "dot_files" user || !user.dot_files.enable then
                null
            else if builtins.hasAttr "path" user.dot_files && user.dot_files.path != null && user.dot_files.path != "" then
                user.dot_files.path
            else if builtins.hasAttr "git" user.dot_files && user.dot_files.git != null && builtins.hasAttr "ssh" user.dot_files.git || builtins.hasAttr "https" user.dot_files.git then
                let
                    useSsh = builtins.hasAttr "ssh" user.dot_files.git && user.dot_files.git.ssh != null &&
                            builtins.hasAttr "enable" user.dot_files.git.ssh && user.dot_files.git.ssh.enable &&
                            builtins.hasAttr "enable" user.ssh && user.ssh.enable &&
                            functions.isPackageEnabled "git";
                    url = if useSsh then
                        builtins.getAttr "url" user.dot_files.git.ssh
                    else
                        builtins.getAttr "url" user.dot_files.git.https;
                in
                    builtins.fetchGit {
                        url = url;
                        ref = user.dot_files.git.ref;
                        rev = user.dot_files.git.commit_id;
                    }
            else
                null;
        getDotFilesUrl = user:
            if user==null then
                null
            else if !builtins.hasAttr "dot_files" user || !user.dot_files.enable then
                null
            else if builtins.hasAttr "git" user.dot_files && user.dot_files.git != null && (builtins.hasAttr "ssh" user.dot_files.git || builtins.hasAttr "https" user.dot_files.git) then
                let
                    useSsh = builtins.hasAttr "ssh" user.dot_files.git && user.dot_files.git.ssh != null &&
                            builtins.hasAttr "enable" user.dot_files.git.ssh && user.dot_files.git.ssh.enable &&
                            builtins.hasAttr "enable" user.ssh && user.ssh.enable &&
                            functions.isPackageEnabled "git";
                    url = if useSsh then
                        builtins.getAttr "url" user.dot_files.git.ssh
                    else
                        builtins.getAttr "url" user.dot_files.git.https;
                in
                    url
            else
                null;                    
        createSymlink = user: src: dest: ''
            mkdir -p $(dirname ${dest})
            ln -sfn ${src} ${dest}
            echo "Created symlink from ${src} to ${dest}" >> /home/${user.username}/debug.log
        '';

        ensureDirectoryExists = dir: ''
            if [ ! -d "${dir}" ]; then
                mkdir -p ${dir}
            fi
        '';

        giveOwnership = user: dir: ''
            ${functions.ensureDirectoryExists dir}
            chown -R ${user.username}:users ${dir}
        '';
        givePermission= dir: permission: ''
            chmod -R ${permission} ${dir}
        '';
        giveAllPermissions = dir: ''
            ${functions.ensureDirectoryExists dir}
            ${functions.givePermission dir "777"}
        '';

        hasInitialPassword = user:
            if !builtins.hasAttr "initialPassword" user || user.initialPassword == null then
                false
            else
                true;
        shouldUseSopsAsPassword= user:
            if !host_vars.sops.enable then
                false
            else if builtins.hasAttr "password" user.initialPassword && user.initialPassword.password != null then
                    user.initialPassword.password
            else if builtins.hasAttr "sops" user.initialPassword && user.initialPassword.sops != null then
                true
            else
                false;

        createUserConfig = user: {
            "${user.username}" = {
                isNormalUser = user.isNormalUser;
                initialPassword = if functions.isWsl then 
                    null 
                else if !functions.hasInitialPassword user then
                    null
                else if functions.shouldUseSopsAsPassword user then
                    null
                else
                    user.initialPassword.password; 
                hashedPasswordFile = if functions.shouldUseSopsAsPassword user then
                    config.sops.secrets.${user.initialPassword.sops}.path
                else
                    null;
                extraGroups = user.extraGroups;
                home = "/home/${user.username}";
                shell = builtins.getAttr user.defaultShell pkgs;
                createHome = true;
                ignoreShellProgramCheck= user.ignoreShellProgramCheck;
            };
        };
        handleDotFilesInWsl= user: dotfiles_path: writableDotfiles: if functions.isGetDotFilesByPath user then ''
            ${functions.logDebug "Creating symlinks for dotfiles in WSL" user}
            ${functions.createSymlink user "${dotfiles_path}" "${writableDotfiles}"}
            ${functions.logDebug "HOST_HOME=$HOST_HOME" user}
        '' else ''
            ${functions.logDebug "Dotfiles are not path" user}
        '';
        handleCommonDotFiles= user: writableDotfiles: ''
            if [ "${toString (functions.isEditorEnabled user "neovim")}" = "1" ]; then
                ${functions.giveAllPermissions "/home/${user.username}/.local/share/nvim"}
                ${functions.giveAllPermissions "/home/${user.username}/.local/state/nvim"}
                ${functions.createSymlink user "${writableDotfiles}/nvim/lua" "/home/${user.username}/.config/nvim/lua"}
                ${functions.createSymlink user "${writableDotfiles}/nvim/init.lua" "/home/${user.username}/.config/nvim/init.lua"}
                ${functions.createSymlink user "${writableDotfiles}/nvim/nvim-mason-install-configuration.json" "/home/${user.username}/.config/nvim/nvim-mason-install-configuration.json"}

            fi
            ${functions.createSymlink user "${writableDotfiles}/starship" "/home/${user.username}/.config/starship"}
            ${functions.createSymlink user "${writableDotfiles}/nushell" "/home/${user.username}/.config/nushell"}
            ${functions.createSymlink user "${writableDotfiles}/zellij" "/home/${user.username}/.config/zellij"}
            ${functions.createSymlink user "${writableDotfiles}/alacritty" "/home/${user.username}/.config/alacritty"}
            
            if [ "${toString functions.isHyprlandEnabled}" = "1" ]; then
              ${functions.createSymlink user "${writableDotfiles}/hyprland/waybar" "/home/${user.username}/.config/waybar"}
            fi
        '';
        handleNotNullDotFiles= user: writableDotfiles: ''
            echo "Dotfiles are not null" >> /home/${user.username}/debug.log
            if [ "${toString isWsl}" = "1" ]; then
                ${functions.handleDotFilesInWsl user writableDotfiles}                
            else
                ${functions.handleDotFilesNotInWsl user writableDotfiles}
            fi
            ${functions.handleCommonDotFiles user writableDotfiles}
        '';
        handleCloneDotFiles= user: writableDotfiles:
        let
            gitPath = "${pkgs.git}/bin/git"; # Absolute path to Git
            sshPath = "${pkgs.openssh}/bin/ssh"; # Absolute path to SSH
            envPath = "${pkgs.coreutils}/bin:${pkgs.git}/bin:${pkgs.openssh}/bin"; # Include necessary paths
            dotFilesUrl = functions.getDotFilesUrl user;
        in
         ''
            if [ ! -d "~/dotfiles" ]; then
              export PATH=${envPath}:$PATH # Set PATH to include necessary binaries
              ${functions.ensureDirectoryExists writableDotfiles}
               
              ${functions.logDebug "Cloning dotfiles" user}
              ${gitPath} clone ${dotFilesUrl} ${writableDotfiles}
              ${functions.giveOwnership user "${writableDotfiles}"}
              ${functions.giveAllPermissions "${writableDotfiles}"}                         
              ${functions.handleCommonDotFiles user writableDotfiles}
              ${functions.logDebug "Dotfiles cloned" user}
            else
              echo "Dotfiles already cloned, skiping..."
            fi
        '';
        hasEditorsConfig = user: 
            if user==null then
                false
            else if !builtins.hasAttr "editors" user || user.editors == null then
                false
            else
                true;
        isEditorsEnabled = user:
            if !functions.hasEditorsConfig user then
                false
            else 
                true;
        hasDefaultEditorConfig = user: 
            if !functions.hasEditorsConfig user then
                false
            else if !builtins.hasAttr "defaultEditor" user.editors || user.editors.defaultEditor == null then
                false
            else
                true;
        isEditorEnabled= user: editor:
            if !functions.isEditorsEnabled user then
                false
            else if !builtins.hasAttr editor user.editors || user.editors.${editor} == null then
                false
            else if !builtins.hasAttr "enable" user.editors.${editor} || user.editors.${editor}.enable == false then
                false
            else
                true;
        useEditorAsDefaultEditor = user: editor:
            if !functions.isEditorEnabled user editor then
                false
            else if functions.hasDefaultEditorConfig user && user.editors.defaultEditor!=editor then
                false
            else 
                true;

        isFirefoxEnabled= user: if !builtins.hasAttr "firefox" user then 
          false
        else if !builtins.hasAttr "enable" user.firefox then 
          false
        else if user.firefox.enable == true then 
          true
        else 
          false;
        isChromiumEnabled = user: if !builtins.hasAttr "chromium" user then 
          false
        else if !builtins.hasAttr "enable" user.chromium then 
          false
        else if user.chromium.enable == true then 
          true
        else 
          false;
        createHomeManagerConfig = user: stateVersion:
        let 
            #dotfiles = functions.getDotFiles user;
              packages = with pkgs; map (program: pkgs.${program}) user.packages; 
              gnomeExtensionsPackages = if lib.hasAttr "gnomeExtensionsPackages" host_vars.host
                  then builtins.map (pkgName: pkgs.gnomeExtensions.${pkgName}) host_vars.host.gnomeExtensionsPackages
                  else [];
        in
        {
                 
            backupFileExtension = "hm-backup";
            users."${user.username}" = lib.mkMerge [{
                    
                home = {
                    homeDirectory = "/home/${user.username}";
                    stateVersion = stateVersion;
                     packages = packages ++ gnomeExtensionsPackages;
                    
                    activation = {
                        postActivate  = ''
                            ${functions.clearLog user}
                            ${functions.logDebug "Creating user config" user}
                            ${functions.getWslInfo user}
                            ${functions.sops.copyKeyFileToUser user}
                            if [ "${toString (functions.hasSshConfig user)}" = "1" ]; then
                                ${functions.ensureDirectoryExists "/home/${user.username}/.ssh"}
                                ${functions.giveOwnership user "/home/${user.username}/.ssh"}
                                chmod 700 "/home/${user.username}/.ssh"
                                ${functions.logDebug "Set ownership and permissions for .ssh directory" user}
                            fi

                            if [ "${toString (functions.isChromiumEnabled user)}" = "1" ]; then
                                ${functions.ensureDirectoryExists "/home/${user.username}/.chromium"}
                                ${functions.giveOwnership user "/home/${user.username}/.chromium"}
                                chmod 700 "/home/${user.username}/.chromium"                            
                                ${functions.logDebug "Set ownership and permissions for .chromium directory" user}
                            fi
                        '';
                    };
                    sessionVariables={
                      terminal = user.defaultTerminal;
                    };
                    
                };
                programs = {
                     neovim = (import ../home/programs/neovim.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
                     zsh = (import ../home/programs/zsh.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
                     ssh = (import ../home/programs/ssh.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
                     git = (import ../home/programs/git.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
                     home-manager = {
                      enable = true;
                     };
                     firefox = (import ../home/programs/firefox.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
                     chromium = (import ../home/programs/chromium.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
                };
                wayland.windowManager.hyprland = (import ../home/hyprland.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config;
              }
              (import ../home/gnome.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; }).config

              ];

        
        };

        setupSshDirScript = user: 
        let
            userSshDir = "/home/${user.username}/.ssh";
        in 
        ''
            ${functions.ensureDirectoryExists userSshDir}
            ${functions.giveOwnership user userSshDir}
            ${functions.givePermission userSshDir "700"}
        '';
        createSshActivationScript = users: lib.concatStringsSep "\n" (map (user: functions.setupSshDirScript user) users);
    };
in
{
    inherit functions;
}   
