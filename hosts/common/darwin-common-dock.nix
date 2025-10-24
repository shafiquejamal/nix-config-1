{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Firefox.app"
      "/Applications/Telegram.app"
      "/Applications/Signal.app"
      "/Applications/Discord.app"
      "/Applications/Ghostty.app"
    ];
  };
}
