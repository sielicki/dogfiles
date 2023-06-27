{inputs}: let
  username = "sielicki";
  homeDirRoot =
    if inputs.nixpkgs.stdenv.isDarwin
    then "/Users"
    else "/home";
  homeDirectory = "${homeDirRoot}/${username}";
in {
  inherit username homeDirectory;
  stateVersion = "23.05";
}
