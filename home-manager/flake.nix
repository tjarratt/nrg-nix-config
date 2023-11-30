{
  description = "Home Manager configuration of tim.jarratt";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/master";
      follows = "nrg/nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nrg = {
      url = "git+ssh://git@github.com/Maersk-Global/nrg?ref=main";
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , nrg
    , ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      homeConfigurations."tim.jarratt" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix nrg.homeManager ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          fullName = "Tim Jarratt";
          emailAddress = "tim.jarratt@maersk.com";
        };
      };
    };
}
