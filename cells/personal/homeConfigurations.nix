{
  inputs,
  cell,
}: {
  personal = {
    bee = {
      pkgs = inputs.nixpkgs;
      home = inputs.home;
      inherit (inputs.nixpkgs) system;
    };
    imports = with cell.homeProfiles; [base personal];
  };
}
