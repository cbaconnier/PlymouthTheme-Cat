{
  description = "Cat Plymouth theme, a sleepy cat boot animation";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "plymouth-theme-cat";
            version = "unstable-2024";
            src = self;

            installPhase = ''
              mkdir -p $out/share/plymouth/themes
              cp -r cat $out/share/plymouth/themes/cat
              find $out/share/plymouth/themes/ -name "*.plymouth" \
                -exec sed -i "s@/usr/@$out/@g" {} \;
            '';

            meta = {
              description = "A sleepy cat Plymouth boot animation";
              homepage = "https://github.com/cbaconnier/PlymouthTheme-Cat";
              license = nixpkgs.lib.licenses.gpl3;
              platforms = nixpkgs.lib.platforms.linux;
            };
          };
        }
      );

      nixosModules.default =
        { pkgs, ... }:
        {
          boot.plymouth = {
            theme = "cat";
            themePackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          };
        };
    };
}
