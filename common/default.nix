{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.home.uid = mkOption {
    type = with types; nullOr int;
    default = null;
    description = ''
      The account UID. If the UID is null, a free UID is picked on
      activation.
    '';
  };

  config = {
    programs.home-manager.enable = true;

    home = {
      packages = with pkgs; [
        wget
        curl
        htop
        doggo
        jq
        tree
      ];
    };
  };
}
