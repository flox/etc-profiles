# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, ... }: let

# ---------------------------------------------------------------------------- #

    eachDefaultSystemMap = let
      defaultSystems = [
        "x86_64-linux"  "aarch64-linux"  "i686-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
    in fn: let
      proc = system: { name = system; value = fn system; };
    in builtins.listToAttrs ( map proc defaultSystems );


# ---------------------------------------------------------------------------- #

    overlays.etc-profiles = import ./overlay.nix;
    overlays.default      = overlays.etc-profiles;


# ---------------------------------------------------------------------------- #

    legacyPackages = eachDefaultSystemMap ( system: let
      nixpkgsFor = builtins.getAttr system nixpkgs.legacyPackages;
      pkgsFor    = nixpkgsFor.extend overlays.default;
    in {
      inherit (pkgsFor) etcProfiles mkEtcProfile;
    } );


# ---------------------------------------------------------------------------- #

  in {
    inherit overlays legacyPackages;
    packages = eachDefaultSystemMap ( system: let
      profiles = ( builtins.getAttr system legacyPackages ).etcProfiles;
      rename   = name: value: { name = "profile-" + name; inherit value; };
    in builtins.listToAttrs ( builtins.attrValues (
      builtins.mapAttrs rename profiles
    ) ) );
  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
