# ============================================================================ #
#
# Creates a starter `<env>/etc/profile' that aggregates
# `<env>/etc/profile.d/*.sh' "child scripts".
#
# ---------------------------------------------------------------------------- #

{ self, inputs, lib, config, bash, coreutils, hostPlatform, system }: let

# ---------------------------------------------------------------------------- #

  ldFloxlib = inputs.ld-floxlib.packages.ld-floxlib;
  pname     = "etc-profiles";
  version   = "0.1.0-${lib.flox-floxpkgs.getRev self}";
  drv       = derivation {
    inherit pname version system ldFloxlib;
    name      = pname + "-" + version;
    builder   = bash.outPath + "/bin/bash";
    outputs   = ["common_paths" "node" "python3" "out"];
    profile   = builtins.path { path = ( toString self ) + "/profile";   };
    profile_d = builtins.path { path = ( toString self ) + "/profile.d"; };
    PATH    = coreutils.outPath + "/bin";
    body    = ''
      mkdir -p "$out/etc"                     \
               "$out/lib"                     \
               "$common_paths/etc/profile.d"  \
               "$node/etc/profile.d"          \
               "$python3/etc/profile.d"       \
      ;
      cp -- "$profile" "$out/etc/profile";

      ${if ! hostPlatform.isLinux then "" else ''
          ln -s -- "$ldFloxlib/lib/"* "$out/lib/";
        ''
       }

      cp -- "$profile_d/0100_common-paths.sh" "$common_paths/etc/profile.d/";
      cp -- "$profile_d/0500_node.sh"         "$node/etc/profile.d/";
      cp -- "$profile_d/0500_python3.sh"      "$python3/etc/profile.d/";
    '';
    passAsFile = "body";
    args       = ["-eu" "-o" "pipefail" "-c" ". $bodyPath;"];
  };


# --------------------------------------------------------------------------- #

in drv // {
  meta = let
    lfm     = ldFloxlib.meta or {};
    license = lib.licenses.mit;
    # Inherit broken from `ld-floxlib'
    broken    = if hostPlatform.isLinux then ( lfm.broken or false ) else false;
    platforms = [
      "x86_64-linux"  "aarch64-linux"  "i686-linux"
      "x86_64-darwin" "aarch64-darwin"
    ];
    unsupported = ! ( builtins.elem hostPlatform.system platforms );
    unfree      = ! license.free;
  in {
    inherit (drv) name;
    inherit license broken platforms unfree unsupported;
    available = ( config.allowBroken            || ( ! broken      ) ) &&
                ( config.allowUnfree            || ( ! unfree      ) ) &&
                ( config.allowUnsupportedSystem || ( ! unsupported ) );
    homepage         = "https://github.com/flox/etc-profiles";
    outputsToInstall = ["common_paths" "python3" "node" "out"];
    description      = ''
      Installable /etc/profile.d activation scripts for use with flox
    '';
    longDescription = ''
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
            # Please note that all/most language packs depend on including
            # the "common_paths" output, and ALL depend on "out".
            meta.outputsToInstall = ["out" "common_paths" "python3"];
          };

          shell.hook = '${""}'
            [[ -r "$FLOX_ENV/etc/profile" ]] && . "$FLOX_ENV/etc/profile";
            pkg-config --list-all >&2;
          '${""}'
        }
    '';
  };
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
