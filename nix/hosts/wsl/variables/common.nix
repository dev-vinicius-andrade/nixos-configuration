{
    system = "x86_64-linux";
    timeZone = "America/Sao_Paulo";
    keyMap = "br-abnt2";
    font = "JetBrainsMono";
    nix = {
        version="24.05";
        packages = {
            repository = "github:NixOS/nixpkgs";
        };
    };
}