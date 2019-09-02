{ config, pkgs, ... }:

{
  imports = [
    #./modules
    #"./configuration/hosts/${config.networking.hostName}"
  ];

  #nixpkgs.overlays = [
  #  (self: super: import ./pkgs { inherit super; })
  #];
}
