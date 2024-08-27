{ pkgs, ... }:

{
  programs.git.extraConfig = {
    core.pager = "${pkgs.delta}/bin/delta";
    diff.colorMoved = "default";
    interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";

    delta = {
      hyperlinks = true;
      navigate = true;
      side-by-side = true;
    };
  };
}
