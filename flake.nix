# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description =
    "Installable /etc/profile.d activation scripts for use with flox";

  inputs.ld-floxlib.url = "github:flox/ld-floxlib/aameen.skip-version";


# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, ld-floxlib, ... }: let

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

    overlays.deps = final: prev: {
      ldFloxlib =
        ( builtins.getAttr final.system ld-floxlib.packages ).ld-floxlib;
    };
    overlays.etc-profiles = final: prev: {
      etc-profiles = final.callPackage ./pkgs/etc-profiles {
        src = builtins.path { path = ./.; };
      };
    };
    overlays.default =
      nixpkgs.lib.composeExtensions overlays.deps overlays.etc-profiles;


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
