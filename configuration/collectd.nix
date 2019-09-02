{ config, pkgs, ... }:

{
  services.collectd.enable = true;

  services.collectd.extraConfig = ''
    LoadPlugin "cpu"
    <Plugin "cpu">
      ValuesPercentage true
    </Plugin>

    LoadPlugin "memory"
    LoadPlugin "swap"
    LoadPlugin "interface"
    LoadPlugin "df"
    LoadPlugin "load"
    LoadPlugin "uptime"
    LoadPlugin "entropy"
    LoadPlugin "dns"
    LoadPlugin "users"

    <Plugin "disk">
      IgnoreSelected true
    </Plugin>

    LoadPlugin "write_prometheus"
    <Plugin "write_prometheus">
      Port "9103"
    </Plugin>

    LoadPlugin "ping"
    <Plugin "ping">
      Host "1.1.1.1"
      Host "8.8.8.8"
    </Plugin>
  '';
}