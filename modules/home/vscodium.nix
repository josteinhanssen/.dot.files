{ pkgs, ... }:
let
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
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Web Development Essentials
        vue.volar
        vue.vscode-typescript-vue-plugin
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

      userSettings = {
        "update.mode" = "none";
        "extensions.autoUpdate" = false; # This stuff fixes vscode freaking out when theres an update
        "window.titleBarStyle" = "custom"; # needed otherwise vscode crashes, see https://github.com/NixOS/nixpkgs/issues/246509

        "window.menuBarVisibility" = "visible";
        "editor.fontFamily" = "'Maple Mono', 'SymbolsNerdFont', 'monospace', monospace";
        "terminal.integrated.fontFamily" = "'Maple Mono', 'SymbolsNerdFont'";
        "editor.fontSize" = 18;
        "workbench.colorTheme" = "Gruvbox Dark Hard";
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

      # Keybindings
      keybindings = [
        {
          key = "ctrl+q";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+s";
          command = "workbench.action.files.saveFiles";
        }
      ];

      # Optional: Add npm/node to your environment
      # (Consider adding these to systemPackages if not already present)
      # systemPackages = with pkgs; [ nodejs npm ];
    };
  };

  # Add basic Node.js tools
  home.packages = with pkgs; [
    fnm
    nodejs
    nodePackages.npm
    nodePackages.pnpm
  ];
}
