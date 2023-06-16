{ self, inputs, lib, buildEnv, runCommand, bash, coreutils, hostPlatform, system }:


let
  pname = "etc-profiles";
  version = "0.1.0-${lib.flox-floxpkgs.getRev self}";
  src = self;
  ld-floxlib = inputs.ld-floxlib.packages.ld-floxlib;

  splitSname = script: let
    sname = baseNameOf script;
    m     = builtins.match "([^_]*)_(.*).sh" sname;
    bname = builtins.elemAt m 1;
  in {
    inherit sname bname;
    priority = builtins.head m;
    pname    = "profile-" + bname;
  };

  base = import ./base.nix {
    inherit self version bash coreutils hostPlatform ld-floxlib lib system;
  };

  mkEtcProfile = import ./mk-profile.nix {
    inherit bash coreutils system;
    version = base.version;
  };

  mkProfileLocal = {
    script
  , description     ? null
  , longDescription ? null
  , ...
  } @ args: let
    ss = splitSname script;
  in {
    name  = lib.replaceStrings ["-"] ["_"] ss.bname;
    value = lib.makeOverridable mkEtcProfile (
      ( removeAttrs ss ["bname"] ) // args
    );
  };

  profiles = builtins.listToAttrs ( map mkProfileLocal [
    { script = src + "/profile.d/0100_common-paths.sh"; }
    { script = src + "/profile.d/0500_node.sh"; }
    { script = src + "/profile.d/0500_python3.sh"; }
  ] );

  etcProfiles = buildEnv {
    name    = pname + "-" + version;
    paths = [ base ] ++ (builtins.attrValues profiles);
  };

in runCommand "etc-profiles.${version}" {
  inherit pname version;
  outputs = [ "out" "base" ] ++ (builtins.attrNames profiles);
  meta.description = "Installable /etc/profile.d activation scripts for use with flox";
} ''
  cp -R -- ${etcProfiles}/. $out
  cp -R -- ${base}/. $base
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList (output: outpath:
    "cp -R -- ${outpath}/. \$${output}") profiles)}
''
