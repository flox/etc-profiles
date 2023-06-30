# ============================================================================ #
#
# Creates a starter `<env>/etc/profile' that aggregates
# `<env>/etc/profile.d/*.sh' "child scripts".
#
# ---------------------------------------------------------------------------- #

{ self       ? inputs.self
, src        ? { inherit (self) outPath; }
, inputs     ? null
, ld-floxlib ? inputs.ld-floxlib
, lib
, config
, bash
, coreutils
, hostPlatform
, system
, ldFloxlib ?
  ( ld-floxlib.packages.${system} or ld-floxlib.packages ).ld-floxlib
}: import ./pkg-fun.nix {
  inherit src lib ldFloxlib config bash coreutils hostPlatform system;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
