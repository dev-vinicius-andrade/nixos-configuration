{common_vars, host_vars, user, ...}:
{config, pkgs, lib, inputs, ...}:

let
  functionsModule = (import ../../system/functions.nix { inherit common_vars host_vars user; } { inherit config lib pkgs inputs; });
  writableDotfiles = "/home/${user.username}/dotfiles";
  isGetDotFilesByPath = if functionsModule.functions.isGetDotFilesByPath user then "1" else "0"; # Ensure correct conversion

  cfg = if functionsModule.functions.isPackageEnabled "zsh" then {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history.expireDuplicatesFirst = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "fzf"
        "golang"
        "helm"
        "dotnet"
        "docker"
        "docker-compose"
        "emoji"
        "eza"
        "direnv"
        "git"
        "zsh-interactive-cd"
      ];
      extraConfig = ''
        zstyle ':completion:*:*:docker:*' option-stacking yes
        zstyle ':completion:*:*:docker-*:*' option-stacking yes
        zstyle ':omz:plugins:docker' legacy-completion yes
      '';
    };
    initExtra = 
    let 
        common_script= ''
            REAL_USER_DOT_FILES_ZSHRC_PATH=$(readlink -f /home/${user.username}/dotfiles/.zshrc)
            if [[ -f "$REAL_USER_DOT_FILES_ZSHRC_PATH" ]]; then
                source "$REAL_USER_DOT_FILES_ZSHRC_PATH"
            fi
            if [ "${toString (functionsModule.functions.isChromiumEnabled user)}" = "1" ]; then
              export GOOGLE_API_KEY="$(cat ~/.chromium/api_key)"
              export GOOGLE_DEFAULT_CLIENT_ID="$(cat ~/.chromium/api_key)"
              export GOOGLE_DEFAULT_CLIENT_SECRET="$(cat ~/.chromium/api_key)"
            fi
        '';
    in
    if functionsModule.functions.isGetDotFilesByPath user then
    ''
        ${functionsModule.functions.logDebug "Creating symlinks for dotfiles in WSL" user}
        ${functionsModule.functions.handleDotFilesInWsl user user.dot_files.path writableDotfiles}
        ${functionsModule.functions.handleCommonDotFiles user writableDotfiles}
        ${common_script}
    ''
    else
    ''
        echo "Cloning dotfiles"
        ${functionsModule.functions.handleCloneDotFiles user writableDotfiles}
        cd "${writableDotfiles}" && git config core.fileMode false
        cd ~
        ${common_script}
    '';
  } else {
    enable = false;
  };

in {
  config = cfg;
}
