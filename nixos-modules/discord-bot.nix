{
  modulesPath,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.discord-bot;
in {
  options = {
    services.discord-bot = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run discord-bot.
        '';
      };
      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ../package.nix {};
        description = "discord-bot package";
      };

      botTokenFile = mkOption {
        type = types.path;
        description = ''
          Discord Bot API token.
        '';
      };

      r34ApiFile = mkOption {
        type = types.path;
        description = ''
          rule34.xxx API user id and token.
        '';
      };

      logLevel = mkOption {
        type = types.str;
        default = "discord-bot=debug";
        description = ''
          Rust log level: https://docs.rs/env_logger/latest/env_logger/#enabling-logging
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.discord-bot = {
      description = "Discord Bot written in Rust";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      environment = {
        RUST_LOG = cfg.logLevel;
        RUST_BACKTRACE = "1";
        BOT_TOKEN_PATH = "%d/bot_token.txt";
        R34_API_PATH = "%d/r34_api.txt";
      };

      serviceConfig = {
        DynamicUser = true;
        LoadCredential = [
          "bot_token.txt:${cfg.botTokenFile}"
          "r34_api.txt:${cfg.r34ApiFile}"
        ];
        StateDirectory = "discord-bot";
        WorkingDirectory = "/var/lib/discord-bot/";
        ExecStart = "${cfg.package}/bin/discord-bot";
        Restart = "always";
        RestartSec = 30;

        # Hardening - look into adding more
        CapabilityBoundingSet = [""];
        AmbientCapabilities = [""];
        NoNewPrivileges = true;
        ProtectSystem = "full";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        PrivateTmp = true;
        LockPersonality = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
