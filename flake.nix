{
  description = "akir-zimfw zsh configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake.homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.azimfw;
          defaultPackages = with pkgs; [
            zsh
            curl
            git
            fd
            fzf
            file
            lua
            bat
            eza
          ];
          hasLsd = builtins.elem pkgs.lsd cfg.extraPackages;
        in
        {
          options.programs.azimfw = {
            enable = lib.mkEnableOption "akir-zimfw zsh configuration";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              defaultText = lib.literalExpression "inputs.azimfw.packages.\${pkgs.stdenv.hostPlatform.system}.default";
              description = "The akir-zimfw package to link into the Home Manager configuration directory.";
            };

            configDir = lib.mkOption {
              type = lib.types.str;
              default = ".config/azimfw";
              example = ".config/azimfw";
              description = "Path relative to the user's home directory where akir-zimfw is linked.";
            };

            extraPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              example = lib.literalExpression "with pkgs; [ lsd jq ]";
              description = "Additional optional packages for akir-zimfw integrations.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.file.${cfg.configDir}.source = cfg.package;

            home.packages = defaultPackages ++ cfg.extraPackages;

            programs.zsh.enable = lib.mkDefault true;
            programs.zsh.initContent = lib.mkAfter ''
              source ${config.home.homeDirectory}/${cfg.configDir}/init.zsh
            '';

            programs.lsd = lib.mkIf hasLsd {
              enable = lib.mkDefault true;
              settings.date = lib.mkDefault "+%Y-%m-%d %H:%M:%S";
            };
          };
        };

      perSystem =
        { pkgs, system, ... }:
        let
          defaultPackages = with pkgs; [
            zsh
            curl
            git
            fd
            fzf
            file
            lua
            bat
            eza
          ];

          azimfwPackage = pkgs.stdenvNoCC.mkDerivation {
            pname = "akir-zimfw";
            version = "2026.06.27";
            src = self;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp -R init.zsh zimrc modules $out/

              runHook postInstall
            '';
          };
        in
        {
          packages.default = azimfwPackage;

          devShells.default = pkgs.mkShell {
            packages =
              defaultPackages
              ++ (with pkgs; [
                nix
                home-manager.packages.${system}.default
              ]);
          };

          checks.package-build = pkgs.runCommand "akir-zimfw-package-build-check" { } ''
            test -f ${azimfwPackage}/init.zsh
            test -f ${azimfwPackage}/zimrc
            test -d ${azimfwPackage}/modules/azim
            touch $out
          '';

          checks.home-manager-module =
            (home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                self.homeManagerModules.default
                {
                  home.username = "azimfw-test";
                  home.homeDirectory = "/home/azimfw-test";
                  home.stateVersion = "26.11";

                  programs.azimfw.enable = true;
                }
              ];
            }).activationPackage;
        };
    };
}
