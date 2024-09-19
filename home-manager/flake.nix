{
  description = "Home Manager configuration of tim.jarratt";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/master";
      follows = "nrg/nixpkgs";
    };
    nrg = {
      # url = "/Users/tim.jarratt/workspace/nrg";
      url = "git@github.com:Maersk-global/nrg.git";
    };
  };

  outputs =
    { nixpkgs
    , nrg
    , ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      homeConfigurations."tim.jarratt" = nrg.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          ./git.nix
          nrg.homeManagerConfig.core
          nrg.homeManagerConfig.neovim
          ./my-special-neovim-config.nix
        ];

        extraSpecialArgs = {
          fullName = "Tim Jarratt";
          emailAddress = "tim.jarratt@maersk.com";
        };
      };
    };
}
