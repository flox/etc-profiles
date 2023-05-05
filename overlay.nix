# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

final: prev: let

# ---------------------------------------------------------------------------- #

  splitSname = script: let
    sname = baseNameOf script;
    m     = builtins.match "([^_]*)_(.*).sh" sname;
    bname = builtins.elemAt m 1;
  in {
    inherit sname bname;
    priority = builtins.head m;
    pname    = "profile-" + bname;
  };


# ---------------------------------------------------------------------------- #

  mkEtcProfile = import ./mk-profile.nix {
    inherit (prev) bash coreutils system;
  };

  mkProfileLocal = {
    script
  , description     ? null
  , longDescription ? null
  , ...
  } @ args: let
    ss = splitSname script;
  in {
    name  = ss.bname;
    value = prev.lib.makeOverridable mkEtcProfile (
      ( removeAttrs ss ["bname"] ) // args
    );
  };


# ---------------------------------------------------------------------------- #

  profiles = builtins.listToAttrs ( map mkProfileLocal [
    { script = ./profile.d/0100_common-paths.sh; }
    { script = ./profile.d/0500_node.sh; }
    { script = ./profile.d/0500_python3.sh; }
  ] );


# ---------------------------------------------------------------------------- #

in {
  inherit mkEtcProfile;
  etcProfiles = profiles // {
    base = import ./base.nix { inherit (prev) bash coreutils system; };
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
