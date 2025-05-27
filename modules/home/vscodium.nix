{ pkgs, ... }:
let
  # Custom extensions definitions (keep your existing ones)
  jonathanharty.gruvbox-material-icon-theme = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "gruvbox-material-icon-theme";
      publisher = "JonathanHarty";
      version = "1.1.5";
      hash = "sha256-86UWUuWKT6adx4hw4OJw3cSZxWZKLH4uLTO+Ssg75gY=";
    };
  };

  ziglang_vscode-zig = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vscode-zig";
      publisher = "ziglang";
      version = "0.6.5";
      hash = "sha256-eFfucWSioF1w4veoO8VAFNi5q2g9JZbZu+NEOuuyHtM=";
    };
  };

  # Base settings that will be merged with current settings
  baseSettings = {
    "update.mode" = "none";
    "extensions.autoUpdate" = false; # This stuff fixes vscode freaking out when theres an update
    "window.titleBarStyle" = "custom"; # needed otherwise vscode crashes, see https://github.com/NixOS/nixpkgs/issues/246509

    "window.menuBarVisibility" = "visible";
    "editor.fontFamily" = "'Maple Mono', 'SymbolsNerdFont', 'monospace', monospace";
    "terminal.integrated.fontFamily" = "'Maple Mono', 'SymbolsNerdFont'";
    "editor.fontSize" = 18;
    "workbench.colorTheme" = "Gruvbox Dark Hard";
    "workbench.preferredDarkColorTheme" = "Gruvbox Dark Hard";
    "workbench.iconTheme" = "gruvbox-material-icon-theme";
    "material-icon-theme.folders.theme" = "classic";
    "vsicons.dontShowNewVersionMessage" = true;
    "explorer.confirmDragAndDrop" = false;
    "editor.fontLigatures" = true;
    "editor.minimap.enabled" = false;
    "workbench.startupEditor" = "none";

    "editor.formatOnSave" = true;
    "editor.formatOnType" = true;
    "editor.formatOnPaste" = true;
    "editor.inlayHints.enabled" = "off";

    "workbench.layoutControl.type" = "menu";
    "workbench.editor.limit.enabled" = true;
    "workbench.editor.limit.value" = 10;
    "workbench.editor.limit.perEditorGroup" = true;
    "workbench.editor.showTabs" = "multiple"; # Show tabs when multiple files are open
    "files.autoSave" = "onWindowChange";
    "explorer.openEditors.visible" = 10; # Show open editors section
    "breadcrumbs.enabled" = true; # Enable breadcrumbs for navigation
    "editor.renderControlCharacters" = false;
    "workbench.activityBar.location" = "default";
    "workbench.statusBar.visible" = true;
    "editor.scrollbar.verticalScrollbarSize" = 10;
    "editor.scrollbar.horizontalScrollbarSize" = 10;
    "editor.scrollbar.vertical" = "auto";
    "editor.scrollbar.horizontal" = "auto";
    "workbench.layoutControl.enabled" = true;

    "editor.mouseWheelZoom" = true;

    # Git
    "git.enableSmartCommit" = true;

    # C/C++
    "clangd.arguments" = [
      "--clang-tidy"
      "--inlay-hints=false"
    ];

    # Zig
    "zig.initialSetupDone" = true;
    "zig.checkForUpdate" = false;
    "zig.zls.path" = "zls";
    "zig.path" = "zig";
    "zig.revealOutputChannelOnFormattingError" = false;
    "zig.zls.enableInlayHints" = false;

    "nix.serverPath" = "nixd";
    "nix.enableLanguageServer" = true;
    # "nix.serverSettings" = {
    #   "nixd" = {
    #     "formatting" = {
    #       "command" = [ "nixfmt" ];
    #     };
    #   };
    # };

    # Vue-specific configuration
    "vue.server.hybridMode" = true;
    "volar.autoCompleteRefs" = true;
    "volar.codeLens.references" = true;
    "volar.codeLens.pugTools" = true;
    "volar.tsPlugin" = true;
    "files.associations" = {
      "*.vue" = "vue";
    };

    # TypeScript/JavaScript
    "typescript.tsdk" = "node_modules/typescript/lib";
    "typescript.preferences.importModuleSpecifier" = "relative";
    "javascript.updateImportsOnFileMove.enabled" = "always";

    # Tailwind CSS
    "tailwindCSS.includeLanguages" = {
      "vue" = "html";
      "typescript" = "html";
      "javascript" = "html";
    };
    "tailwindCSS.emmetCompletions" = true;
    "editor.quickSuggestions" = {
      "strings" = true; # Enable autocomplete in CSS strings
    };

    # ESLint
    "eslint.format.enable" = true;
    "eslint.lintTask.enable" = true;
    "eslint.probe" = [
      "typescript"
      "typescriptreact"
      "javascript"
      "javascriptreact"
      "vue"
    ];

    # Formatting Configuration
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[vue]" = {
      "editor.defaultFormatter" = "vue.volar";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[javascript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };

    # Emmet for Vue files
    "emmet.includeLanguages" = {
      "vue-html" = "html";
      "vue" = "html";
    };
  };

  # Merge script (now uses your baseSettings)
  mergeVSCodiumSettingsScript = pkgs.writeScript "merge-vscodium-settings" ''
    #!${pkgs.bash}/bin/bash
    VSCODIUM_USER_SETTINGS="$HOME/.config/VSCodium/User/settings.json"
    mkdir -p "$(dirname "$VSCODIUM_USER_SETTINGS")"
    
    # Get current settings (or empty object if file doesn't exist)
    currentSettings=$(cat "$VSCODIUM_USER_SETTINGS" 2>/dev/null || echo '{}')
    
    # Merge with Nix-defined base settings
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
      <(echo '${builtins.toJSON baseSettings}') \
      <(echo "$currentSettings") > "$VSCODIUM_USER_SETTINGS.tmp"
    
    # Only overwrite if changes detected
    if ! cmp -s "$VSCODIUM_USER_SETTINGS.tmp" "$VSCODIUM_USER_SETTINGS"; then
      mv "$VSCODIUM_USER_SETTINGS.tmp" "$VSCODIUM_USER_SETTINGS"
    else
      rm "$VSCODIUM_USER_SETTINGS.tmp"
    fi
  '';

in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Web Development Essentials
        vue.volar
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        stylelint.vscode-stylelint

        # Misc extensions
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        llvm-vs-code-extensions.vscode-clangd
        ziglang_vscode-zig
        jdinhlife.gruvbox
        jonathanharty.gruvbox-material-icon-theme
        rooveterinaryinc.roo-cline
      ];
    };
  };

  home.activation = {
    mergeVSCodiumSettings = "bash ${mergeVSCodiumSettingsScript}";
  };

  # Ensure jq is available for the merge script
  home.packages = with pkgs; [ 
    jq
    fnm
    nodejs
    nodePackages.npm
    nodePackages.pnpm
  ];
}

