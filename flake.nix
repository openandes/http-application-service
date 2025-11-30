{
  description = "A production-ready Go web server built with Nix on the Anduril Determined Nix environment.";

  inputs = {
    # 1. nixpkgs: The main collection of Nix packages
    # We use the 'github:' URL scheme targeting a stable branch (e.g., 'nixos-23.11'). 
    # This is the standard, most reliable, and declarative way for GitHub inputs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; 

    # 2. The Go development workbench flake from FlakeHub
    # This uses the full HTTPS URL which resolves to an archive via the FlakeHub API.
    gnu-nix-go.url = "https://flakehub.com/f/Open-Andes/gnu-nix-go/0.1.0";
  };

  outputs = { self, nixpkgs, gnu-nix-go, ... }:
    let
      # Define the systems we want to build for
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Helper function to generate outputs for all supported systems
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # An instance of nixpkgs for each system
      pkgs = forAllSystems (system: import nixpkgs {
        inherit system;
      });
      
    in {
      
      ## 1. The Package Output (The compiled executable)
      packages = forAllSystems (system:
        let
          pkgs = pkgs.${system};
        in {
          default = pkgs.buildGoModule rec {
            pname = "my-web-server";
            version = "0.1.0";
            
            src = self;
            # NOTE: You must calculate and REPLACE this hash after the first `nix build` failure.
            vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
            
            # Use 'main' if your executable is not built from the main package
            # buildFlagsArray = [ "-ldflags=-s -w" ]; # Optimization flags
            
            meta = with pkgs.lib; {
              description = "My production Go web server.";
              license = licenses.mit;
            };
          };
        }
      );

      ## 2. The Application Output (The executable wrapper for running)
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/my-web-server";
        };
      });

      ## 3. The Development Shell (Re-uses the Go environment)
      devShells = forAllSystems (system: {
        default = gnu-nix-go.devShells.${system}.default;
      });
      
    };
}
