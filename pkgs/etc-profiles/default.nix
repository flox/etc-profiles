{ self, lib, buildEnv, runCommand, bash, coreutils, system }:

let
  pname = "etc-profiles";
  version = "0.1.0-${lib.flox-floxpkgs.getRev self}";
  src = self;

  splitSname = script: let
    sname = baseNameOf script;
    m     = builtins.match "([^_]*)_(.*).sh" sname;
    bname = builtins.elemAt m 1;
  in {
    inherit sname bname;
    priority = builtins.head m;
    pname    = "profile-" + bname;
  };

  base = import ./base.nix { inherit self version bash coreutils system; };

  mkEtcProfile = import ./mk-profile.nix {
    inherit base bash coreutils system;
  };

  mkProfileLocal = {
    script
  , description     ? null
  , longDescription ? null
  , ...
  } @ args: let
    ss = splitSname script;
  in {
    name  = ss.bname;
    value = lib.makeOverridable mkEtcProfile (
      ( removeAttrs ss ["bname"] ) // args
    );
  };

  profiles = builtins.listToAttrs ( map mkProfileLocal [
    { script = src + "/profile.d/0500_node.sh"; }
    { script = src + "/profile.d/0500_python3.sh"; }
  ] );

  etcProfiles = buildEnv {
    name    = pname + "-" + version;
    paths = [ base ] ++ (builtins.attrValues profiles);
  };

in runCommand "etc-profiles.${version}" {
  inherit pname version;
  outputs = [ "out" ] ++ (builtins.attrNames profiles);
  meta.description = "an example flox package";
} ''
  cp -R ${etcProfiles}/. $out
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList (output: outpath:
    "cp -R ${outpath}/. \$${output}") profiles)}
''
