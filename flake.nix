{
  description = "Discord Bot";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = nixpkgs.legacyPackages;
  in {
    packages = forAllSystems (system: {
      default =
        pkgsFor.${system}.callPackage ./package.nix {};
    });
    devShells = forAllSystems (system: {
      default = pkgsFor.${system}.callPackage ./shell.nix {};
    });

    nixosModules.default = import ./nixos-modules/discord-bot.nix;
  };
}
