# ============================================================================ #
#
# Creates a starter `<env>/etc/profile' that aggregates
# `<env>/etc/profile.d/*.sh' "child scripts".
#
# ---------------------------------------------------------------------------- #

{ inputs
, lib
, config
, bash
, coreutils
, hostPlatform
, system
}: import ./pkg-fun.nix {
  inherit lib config bash coreutils hostPlatform system;
  inherit (inputs.ld-floxlib.packages) ld-floxlib;
  src = inputs.self;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
