{ config, pkgs, lib, ... }:

let
  secrets = import /etc/nixos/secrets.nix;
  netFace = "enp2s0f0";
in {
  imports = [
    ../../default.nix
    (builtins.fetchGit {
      url = "https://github.com/kloenk/nix.git";
      rev = "99a16f578e5a68600fd23902ad9ee6699f77b3ce";
    } + "/configuration/users.nix")
    ../users/sarius.nix
    ../ssh.nix
    ../collectd.nix
    ../services/mongodb.nix

    # fallback for detection
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x600300570190366024ffdf35240f5963";

  # f2fs support
  boot.supportedFilesystems = [ "ext4" "ext2" "nfs" "cifs" ];

  # taken from hardware-configuration.nix
  boot.initrd.availableKernelModules = [
   "ehci_pci"
   "ahci"
   "megaraid_sas"
   "usb_storage"
   "usbhid"
   "sd_mod"
   "sr_mod"
  ];
  boot.kernelModules = [ "kvm-intel" "acpi_call" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.acpi_call
    config.boot.kernelPackages.wireguard
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e9eb2837-0227-41a4-b70f-d87c34b737c6";
      fsType = "ext4";
    };

  swapDevices = [
    { device = "/dev/disk/by-label/nixos-swap"; }
  ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  # enable autotune for linux with powertop (intel)
  #powerManagement.powertop.enable = true; # auto tune software

  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "io";
  networking.extraHosts = ''
    172.16.0.1 airlink.local unit.local
    10.0.0.1 lycus lycus.llg
  '';
  networking.nameservers = [ "10.0.0.2" "8.8.8.8" ];
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.interfaces."${netFace}".ipv4.addresses = [ { address = "10.0.0.4"; prefixLength = 8; } ];
  networking.defaultGateway = { address = "10.1.0.1"; interface = netFace; };

  services.vnstat.enable = true;

  # auto update/garbage collector
  system.autoUpgrade.enable = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 5d";

  # fix tar gz error in autoupdate
  systemd.services.nixos-upgrade.path = with pkgs; [  gnutar xz.bin gzip config.nix.package.out ];


  #networking.wireguard.interfaces = {
  #  wg0 = {
  #    ips = [ "192.168.42.6/24" "2001:41d0:1004:1629:1337:187:1:6/120" ];
  #    privateKeyFile = "/etc/nixos/secrets/wg0.key";
  #    peers = [ 
  #      {
  #        publicKey = "MUsPCkTKHBGvCI62CevFs6Wve+cXBLQIl/C3rW3PbVM=";
  #        allowedIPs = [ "192.168.42.0/24" "2001:41d0:1004:1629:1337:187:1:0/120" "2001:41d0:1004:1629:1337:187:0:1/128" ];
  #        endpoint = "51.254.249.187:51820";
  #        persistentKeepalive = 21;
  #        presharedKeyFile = "/etc/nixos/secrets/wg0.psk";
  #      }
  #    ];
  #  };
  #};

  nixpkgs.config.allowUnfree = true;

  #services.logind.lidSwitch = "ignore";
  users.users.kloenk.packages = with pkgs; [
    lm_sensors
    python                 # includes python2 as dependency for vscode

    docker
    virtmanager
  ];


  # docker fo
  virtualisation.docker.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  users.users.kloenk.extraGroups = [
    "dialout"  # allowes serial connections
    "plugdev"  # allowes stlink connection
    "davfs2"   # webdav foo
    "docker"   # docker controll group
    "libvirt"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03";
}
