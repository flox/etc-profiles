# ============================================================================ #
#
# Creates a starter `<env>/etc/profile' that aggregates
# `<env>/etc/profile.d/*.sh' "child scripts".
#
# ---------------------------------------------------------------------------- #

{ bash, coreutils, system }: let
  pname   = "profile-base";
  version = "0.1.0";
in ( derivation {
  inherit system pname version;
  #script  = builtins.path { path = ./profile; };
  script  = ./profile;
  name    = pname + "-" + version;
  builder = bash.outPath + "/bin/bash";
  PATH    = coreutils.outPath + "/bin";
  args    = ["-eu" "-o" "pipefail" "-c" ''
    mkdir -p "$out/etc";
    cp -- "$script" "$out/etc/profile";
  ''];
  preferLocalBuild = true;
  allowSubstitutes = system == ( builtins.currentSystem or null );
} ) // {
  meta.description =
   "An `<env>/etc/profile' script to source `<env>/etc/profile.d/*.sh`";
  meta.longDescription = ''
    An `<env>/etc/profile' script to source `<env>/etc/profile.d/*.sh`

    Users can define and install scripts in `<env>/etc/profile.d' as
    "custom packages"/installables to share common setup processes
    across environments.

    Recommended usage:
      # flox.nix
      {
        packages.nixpkgs-flox.sqlite = {
          meta.outputsToInstall = ["bin" "out" "dev"];
        };
        packages.nixpkgs-flox.pkg-config = {};
        # Provides `<env>/etc/profile' base.
        packages."github:flox/etc-profiles".profile-base = {};
        # Adds `0100_common-paths.sh' to `<env>/etc/profile.d/'.
        packages."github:flox/etc-profiles".profile-common-paths = {};

        shell.hook = '${""}'
          [[ -r "$FLOX_ENV/etc/profile" ]] && . "$FLOX_ENV/etc/profile";
          pkg-config --list-all >&2;
        '${""}'
      }
  '';
  meta.outputsToInstall = ["out"];
  meta.platforms        = [
    "x86_64-linux"  "aarch64-linux"  "i686-linux"
    "x86_64-darwin" "aarch64-darwin"
  ];
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
