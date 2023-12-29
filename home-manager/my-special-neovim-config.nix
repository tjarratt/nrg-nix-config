{ pkgs, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
    ];

    extraLuaConfig = builtins.readFile ./my-extras.lua;
  };
}
