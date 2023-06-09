# -*- mode: sh -*-
# ============================================================================ #
#
# Source all profile scripts.
#
# ---------------------------------------------------------------------------- #

# Save and set shell options used during this script.
# The original settings are restored when exiting.
_old_opts="$( set +o; )";
set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

# Locate the directory containing this script, and the env root.
_me="${BASH_SOURCE[0]:-${(%):-%x}}";
if [ -z "${FLOX_ENV:-}" ]; then
  _etcdir="$( cd "${_me%/*}" >/dev/null; echo "$PWD"; )";
  FLOX_ENV="${_etcdir%/*}";
  unset _etcdir;
fi

export FLOX_ENV;


# ---------------------------------------------------------------------------- #

detect_shell() {
  if [ -n "${0:-}" ]; then
    case "${0##*/}" in
      bash|zsh|ksh|sh|fish|dash) echo "${0##*/}"; return 0; ;;
      *) :; ;;
    esac
  fi
  if [ -n "${BASH_SOURCE:-}" ]; then echo "bash"; return 0; fi
  if [ -n "${(%):-}" ];         then echo "zsh";  return 0; fi
  if [ -n "${SHELL:-}" ]; then
    case "${SHELL##*/}" in
      bash|zsh|ksh|sh|fish|dash) echo "${SHELL##*/}"; return 0; ;;
      *) :; ;;
    esac
  fi
  return 1;
}


# ---------------------------------------------------------------------------- #

if [ -d "$FLOX_ENV/etc/profile.d" ]; then
  declare -a _prof_scripts;
  _prof_scripts=( $(
    case "$( detect_shell; )" in
      zsh) set -o nullglob; ;;
      *)   shopt -s nullglob; ;;
    esac
    echo "$FLOX_ENV/etc/profile.d"/*.sh;
  ) );
  for p in "${_prof_scripts[@]}"; do . "$p"; done
  unset _prof_scripts;
fi


# ---------------------------------------------------------------------------- #

# Restore shell options.
eval "$_old_opts";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
