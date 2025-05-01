{ config, pkgs, lib, ... }:

let
  myAliases = {
      la = "ls -la";
      nrs = "nixos-rebuild switch --flake . --use-remote-sudo";
      hms = "home-manager switch --flake .";
    };
in 
{
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jostein";
  home.homeDirectory = "/home/jostein";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jostein/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    SUDO_EDITOR = "nvim";
    VISUAL = "nvim";
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # VS code - because I don't nvim too well
  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      brettm12345.nixfmt-vscode
    ];

  };

  programs.bash = {
    enable = true;
    shellAliases = myAliases;
  };

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
  };

  #Hyprland
  xdg.configFile."hypr/hyprland.conf".source = ./hypr/hyprland.conf;
  xdg.configFile."hypr/ENVariables.conf".source = ./hypr/ENVariables.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./hypr/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
  xdg.configFile."hypr/scripts/keyboard-switcher.sh".source = ./hypr/scripts/keyboard-switcher.sh;
  xdg.configFile."rofi/config.rasi".source = ./rofi/config.rasi;  
  xdg.configFile."rofi/catppuccin-lavrent-mocha.rasi".source = ./rofi/catppuccin-lavrent-mocha.rasi;

  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["thunar.desktop"];
      "application/x-gnome-saved-search" = ["thunar.desktop"];
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        timeout = 5;  # 5 seconds
        corner_radius = 10;
        frame_width = 2;
        frame_color = "#89b4fa";
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        font = "JetBrainsMono Nerd Font 11";
      };
    };
  };

  home.activation = {
    reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Attempting to reload Hyprland configuration..."
      if ${pkgs.hyprland}/bin/hyprctl monitors > /dev/null 2>&1; then
        # Hyprland is running if hyprctl monitors succeeds
        echo "Hyprland detected, reloading configuration..."
        ${pkgs.hyprland}/bin/hyprctl reload
        ${pkgs.libnotify}/bin/notify-send "Home Manager" "Configuration updated and Hyprland reloaded"
      else
        echo "Hyprland is not running, skipping reload"
      fi
    '';
  };
}
