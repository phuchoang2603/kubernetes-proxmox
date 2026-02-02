{
  description = "Development environment for kubernetes-proxmox project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              terraform
              ansible
              ansible-lint

              kubectl
              kubernetes-helm
              kubectx
              vault

              # This creates a custom command called 'load-secrets'
              (writeShellScriptBin "load-secrets" ''
                read -sp "Enter Vault Token: " input_token
                export VAULT_ADDR="https://vault.home.phuchoang.sbs"
                export VAULT_TOKEN=$input_token
                export AWS_ACCESS_KEY_ID=$(vault kv get -field=access_key kv/shared/minio)
                export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secret_key kv/shared/minio)
                echo -e "\n✅ Minio credentials loaded into environment."
                exec "$SHELL"
              '')
            ];
          };
        }
      );
    };
}
