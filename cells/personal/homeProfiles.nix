{
  inputs,
  cell,
}: {
  base = inputs.hive.load {
    inherit inputs cell;
    src = ./homeProfiles/base;
  };
  personal = inputs.hive.load {
    inherit inputs cell;
    src = ./homeProfiles/personal;
  };
  graphical = inputs.hive.load {
    inherit inputs cell;
    src = ./homeProfiles/graphical;
  };
}
