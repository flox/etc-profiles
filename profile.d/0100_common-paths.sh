# ============================================================================ #
#
# Setup common paths.
#
# ---------------------------------------------------------------------------- #

PATH="$FLOX_ENV/bin:$FLOX_ENV/sbin${PATH:+:$PATH}";
FPATH="$FLOX_ENV/share/zsh/vendor-completions${FPATH:+:$FPATH}";
FPATH="$FLOX_ENV/share/zsh/site-functions:$FPATH";
MANPATH="$FLOX_ENV/share/man${MANPATH:+:$MANPATH}";
INFOPATH="$FLOX_ENV/share/info${INFOPATH:+:$INFOPATH}";
CPATH="$FLOX_ENV/include${CPATH:+:$CPATH}";
LIBRARY_PATH="$FLOX_ENV/lib${LIBRARY_PATH:+:$LIBRARY_PATH}";
PKG_CONFIG_PATH="$FLOX_ENV/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}";
PKG_CONFIG_PATH="$FLOX_ENV/lib/pkgconfig:$PKG_CONFIG_PATH";
ACLOCAL_PATH="$FLOX_ENV/share/aclocal${ACLOCAL_PATH:+:$ACLOCAL_PATH}";
XDG_DATA_DIRS="$FLOX_ENV/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}";

export             \
  PATH             \
  FPATH            \
  MANPATH          \
  INFOPATH         \
  CPATH            \
  LIBRARY_PATH     \
  PKG_CONFIG_PATH  \
  ACLOCAL_PATH     \
  XDG_DATA_DIRS    \
;

case "$(uname -s)" in
Linux*)
  if [ -z "${FLOX_NOSET_LD_AUDIT:-}" -a -e "$FLOX_ENV/lib/ld-floxlib.so" ]; then
    LD_AUDIT="$FLOX_ENV/lib/ld-floxlib.so";
    export LD_AUDIT;
  fi
  ;;
Darwin*)
  DYLD_FALLBACK_LIBRARY_PATH="$FLOX_ENV/lib:${DYLD_FALLBACK_LIBRARY_PATH:-/usr/local/lib:/usr/lib}";
  export DYLD_FALLBACK_LIBRARY_PATH;
  ;;
esac

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
