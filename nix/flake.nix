{
  description = "Default flake and disko";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows ="hyprland";
    };
  };

  outputs = { self, nixpkgs, disko,home-manager, sops-nix, nixos-wsl,... }@inputs:

    let
      example_vars = import ./hosts/example/variables/common.nix;
      wsl_vars = import ./hosts/wsl/variables/common.nix;
      flake_file_path = ./.;
    in
   {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    defaultPackage.x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
    nixosConfigurations = {
        example = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs flake_file_path;};
          system = example_vars.system;
          modules = [
            disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            home-manager.nixosModules.home-manager
            ./disko/default/disko.nix
            ./hosts/example/hardware-configuration.nix
            ./hosts/example/configuration.nix          
          ];
        };
        wsl = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs flake_file_path;};
          system = wsl_vars.system;
          modules = [
            home-manager.nixosModules.home-manager
            nixos-wsl.nixosModules.default
            ./hosts/wsl/configuration.nix 
          ];
        };
        nixos-home-server = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs flake_file_path;};
          system = example_vars.system;
          modules = [
            disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            home-manager.nixosModules.home-manager   
            ./disko/default/disko.nix
            ./hosts/nixos-home-server/hardware-configuration.nix
            ./hosts/nixos-home-server/configuration.nix          
          ];
        };
        personal = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs flake_file_path;};
          system = example_vars.system;
          modules = [
            disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            home-manager.nixosModules.home-manager   
            ./disko/personal/disko.nix
            ./hosts/personal/hardware-configuration.nix
            ./hosts/personal/configuration.nix          
          ];
        };
      };
  };
}
