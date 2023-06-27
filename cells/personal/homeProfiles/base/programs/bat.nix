{inputs}: {
  enable = true;
  config = {
    map-syntax = ["*.jenkinsfile:Groovy" "*.props:Java Properties"];
  };
  extraPackages = with inputs.nixpkgs.bat-extras; [
    #batman
    batgrep
    batpipe
    batwatch
    batdiff
    prettybat
  ];
}
