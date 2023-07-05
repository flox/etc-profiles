# ============================================================================ #
#
# Creates a starter `<env>/etc/profile' that aggregates
# `<env>/etc/profile.d/*.sh' "child scripts".
#
# ---------------------------------------------------------------------------- #

{ src        ? inputs.self or ( builtins.path { path = ../..; } )
, inputs     ? null
, ld-floxlib ? inputs.ld-floxlib or null
, lib
, config
, bash
, coreutils
, hostPlatform
, system
, ldFloxlib ? if ld-floxlib == null then null else
  ( ld-floxlib.packages.${system} or ld-floxlib.packages ).ld-floxlib
}: import ./pkg-fun.nix {
  inherit src lib ldFloxlib config bash coreutils hostPlatform system;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
