{
  description = "Personal interception-vimproved fork";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }: {
    overlays.default = final: prev: {
      interception-vimproved-personal = final.stdenv.mkDerivation {
        pname = "interception-vimproved-personal";
        version = "git";

        # this flake's source
        src = self;

        nativeBuildInputs = [ final.gnumake final.pkg-config ];
        buildInputs       = [ final.libevdev final.udev ];

        buildPhase = "make";

        installPhase = ''
          mkdir -p $out/bin
          cp interception-vimproved $out/bin/
        '';
      };
    };

    nixosModules.interception-vimproved-personal = { config, pkgs, ... }: {
      hardware.uinput.enable = true;

      services.interception-tools = {
        enable = true;
        plugins = [ ];

        udevmonConfig = ''
          - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE \
                  | ${pkgs.interception-vimproved-personal}/bin/interception-vimproved \
                  | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
            DEVICE:
              NAME: ".*(Keyboard|keyboard|kbd).*"
        '';
      };
    };
  };
}