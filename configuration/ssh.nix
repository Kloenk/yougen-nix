{ config, pkgs, ... }:

{
  services.openssh.enable = true;
  services.openssh.ports = [ 62954 ];

  users.users.kloenk.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISCKsWIhN2UBenk0kJ1Hnc+fCZC/94l6bX9C4KFyKZN cardno:FFFE43212945" ];

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISCKsWIhN2UBenk0kJ1Hnc+fCZC/94l6bX9C4KFyKZN cardno:FFFE43212945" ];
}
