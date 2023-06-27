{cell, ...}: {
  colmena = {
    networking.hostName = "dogleg";
    deployment = {
      allowLocalDeployment = true;
      targetHost = null;
    };
    imports = [cell.darwinConfigurations.dogleg];
  };
}
