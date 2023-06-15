# ============================================================================ #
#
# Creates a starter `<env>/etc/profile' that aggregates
# `<env>/etc/profile.d/*.sh' "child scripts".
#
# ---------------------------------------------------------------------------- #

{ self, version, bash, coreutils, ld-floxlib, system }: let
  pname   = "profile-base";
in ( derivation {
  inherit system pname version;
  name    = pname + "-" + version;
  builder = bash.outPath + "/bin/bash";
  PATH    = coreutils.outPath + "/bin";
  args    = ["-eu" "-o" "pipefail" "-c" ''
    mkdir -p "$out/etc" "$out/lib";
    cp -- ${self}/profile "$out/etc/profile";
    for i in ${ld-floxlib}/lib/*; do
      ln -s "$i" "$out/lib/$(basename $i)";
    done
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

        # Provides developer environment hooks for use with python3.
        packages.flox.etc-profiles = {
          # Optionally, specify language packages to install.
          # Invoke `flox search -c flox etc-profiles -l` to see
          # a list of all supported language pack outputs. Please
          # note that all/most language packs depend on including
          # the "common_paths" output.
          meta.outputsToInstall = [ "base" "common_paths" "python3" ];
        };

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
