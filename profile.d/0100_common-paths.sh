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

# Use `FLOX_SET_LD_LIBRARY_PATH' to a non-empty string to use `LD_LIBRARY_PATH'.
# This is turned off by default in favor of the `LD_AUDIT' ( Linux ) and
# `DYLD_FALLBACK_LIBRARY_PATH' ( Darwin ) which are less likely to cause
# conflicts with executables built outside of `flox'.
if [ -n "${FLOX_SET_LD_LIBRARY_PATH:-}" ]; then
  LD_LIBRARY_PATH="$FLOX_ENV/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}";
  export LD_LIBRARY_PATH;
fi

# By default on Linux: all executables run from an activated shell will operate
# with an intermediary between them and the system's dynamic loader using the
# `LD_AUDIT' interface of `ld-linux.so'.
# This allows failed library lookups to search `FLOX_ENV' for suitable
# libraries at runtime and build-time.
if [ -z "${FLOX_NOSET_LD_AUDIT:-}" ] && [ -e "$FLOX_ENV/lib/ld-floxlib.so" ];
then
  LD_AUDIT="$FLOX_ENV/lib/ld-floxlib.so";
  export LD_AUDIT;
fi

# By default on Darwin: we append `DYLD_FALLBACK_LIBRARY_PATH' which indicates
# to the system loader that we would like to add "low priority" search paths.
# This allows failed library lookups to search `FLOX_ENV' for suitable
# libraries at runtime and build-time.
if [ -z "${FLOX_NOSET_DYLD_FALLBACK:-}" ]; then
  case "$( uname; )" in
    [dD]arwin*)
      : "${DYLD_FALLBACK_LIBRARY_PATH:=/usr/local/lib:/usr/lib}";
      DYLD_FALLBACK_LIBRARY_PATH="$FLOX_ENV/lib:$DYLD_FALLBACK_LIBRARY_PATH";
      export DYLD_FALLBACK_LIBRARY_PATH;
    ;;
    *)
      :;
    ;;
  esac
fi


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
