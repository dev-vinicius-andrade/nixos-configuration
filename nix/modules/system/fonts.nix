{common_vars,host_vars, ...}:
{config,lib,pkgs,...}:{
    config={
        fonts.enableDefaultPackages = true;
        fonts.packages= with pkgs;[
            (nerdfonts.override {fonts=["JetBrainsMono" "Hack" "Terminus" "NerdFontsSymbolsOnly"];})
         ];
    };
}
