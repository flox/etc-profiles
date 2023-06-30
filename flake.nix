# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description =
    "Installable /etc/profile.d activation scripts for use with flox";


# ---------------------------------------------------------------------------- #

  outputs = { self, nixpkgs, ... } @ inputs: let

# ---------------------------------------------------------------------------- #

    eachDefaultSystemMap = let
      defaultSystems = [
        "x86_64-linux"  "aarch64-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
    in fn: let
      proc = system: { name = system; value = fn system; };
    in builtins.listToAttrs ( map proc defaultSystems );


# ---------------------------------------------------------------------------- #

    overlays.etc-profiles = final: prev: {
      etc-profiles = final.callPackage ./pkgs/etc-profiles {
        src = if self.sourceInfo ? rev then self else
              builtins.path { path = ./.; };
        ldFloxlib = null;  # FIXME
        inherit inputs;
      };
    };
    overlays.default = overlays.etc-profiles;


# ---------------------------------------------------------------------------- #

    legacyPackages = eachDefaultSystemMap ( system: let
      nixpkgsFor = builtins.getAttr system nixpkgs.legacyPackages;
      pkgsFor    = nixpkgsFor.extend overlays.default;
    in {
      inherit (pkgsFor) etc-profiles;
    } );

# ---------------------------------------------------------------------------- #

  in {

    inherit overlays legacyPackages;

    packages = eachDefaultSystemMap ( system: {
      inherit (builtins.getAttr system legacyPackages) etc-profiles;
      default = ( builtins.getAttr system legacyPackages ).etc-profiles;
    } );

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
