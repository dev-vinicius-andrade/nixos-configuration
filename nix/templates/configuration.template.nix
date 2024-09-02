{ config,pkgs,lib,home-manager, ... }:
let
    common_vars = import ../../variables/common.nix;
    host_vars= import ./variables/host.nix;
in
{
    ## Add Imports Configuration Here
    imports = [
        (import ../../configurations/common/configuration.nix {common_vars = common_vars; host_vars=host_vars;})
        ./hardware-configuration.nix
    ];
    ## Add Hosts Configuration Here
}