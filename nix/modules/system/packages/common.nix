{common_vars, host_vars}: {config, lib, pkgs, ...}:
let 
  hostPackages = builtins.map (pkgName: pkgs.${pkgName}) host_vars.host.packages;
  gnomePackages = if lib.hasAttr "gnomePackages" host_vars.host
                  then builtins.map (pkgName: pkgs.gnome.${pkgName}) host_vars.host.gnomePackages
                  else [];
in
{
  environment.systemPackages = hostPackages ++ gnomePackages;
}
