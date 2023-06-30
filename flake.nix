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

  outputs = { self, nixpkgs, ... }: let

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
        src       = builtins.path { path = ./.; };
        ldFloxlib = null;  # FIXME
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

    packages = eachDefaultSystemMap ( system: {
      inherit (builtins.getAttr system legacyPackages) etc-profiles;
      default = ( builtins.getAttr system legacyPackages ).etc-profiles;
    } );

    mkCatalog = eval: eachDefaultSystemMap ( system: let
      pkg = ( builtins.getAttr system packages ).etc-profiles;
      withMeta = pkg // {
        meta.publishData = {
          cache   = [];
          element = {
            attrPath    = ["packages" system "etc-profiles"];
            storePaths  = map ( o: o.outPath ) pkg.all;
            originalUrl = "github:flox/etc-profiles" + (
                if self.sourceInfo ? rev then "/" + self.sourceInfo.rev else
                if self.sourceInfo ? ref then "/" + self.sourceInfo.ref else ""
            );
          };
          type          = "catalogRender";
          version       = 2;
          eval          = pkg.meta;
          source.locked = builtins.intersectAttrs {
            lastModified = true;
            revCount     = true;
          } self.sourceInfo;
        };
      };
    in {
      stable.etc-profiles."0_1_0"  = if eval then pkg else withMeta;
      stable.etc-profiles."latest" = if eval then pkg else withMeta;
    } );


# ---------------------------------------------------------------------------- #

  in {

    inherit overlays legacyPackages packages;
    catalog     = mkCatalog false;
    evalCatalog = mkCatalog true;

  };


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
