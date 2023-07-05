{
  description =
    "Installable /etc/profile.d activation scripts for use with flox";

  inputs.flox-floxpkgs.url = "github:flox/floxpkgs";
  inputs.ld-floxlib.url    = "github:flox/ld-floxlib";

  outputs = args @ {flox-floxpkgs, ...}: flox-floxpkgs.project args (_: {});
}
