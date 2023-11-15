{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  time.timeZone = "America/Detroit";
  users.users.it = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  environment.systemPackages = with pkgs; [
    wget
  ];
  services.openssh.enable = true;
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "it";
    windowManager.openbox.enable = true;
  };
  nixpkgs.overlays = with pkgs; [
    (_self: super: {
      openbox = super.openbox.overrideAttrs (_oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];
  environment.etc."openbox/autostart".text = ''
    #!${pkgs.bash}/bin/bash
    firefox --kiosk https://aadl.org/ &
  '';
  programs.firefox = {
    enable = true;
    policies = {
      BlockAboutConfig = true;
      DisableDeveloperTools = true;
      DisableFormHistory = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      NewTabPage = false;
      OfferToSaveLogins = false;
      Homepage = {
        URL = "https://aadl.org";
        Locked = true;
        StartPage = "homepage";
      };
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
      UserMessaging = {
        ExtensionRecommendation = false;
        SkipOnboarding = true;
        WhatsNew = false;
      };
    };
  };
  system.stateVersion = "23.05"; # Did you read the comment?

}
