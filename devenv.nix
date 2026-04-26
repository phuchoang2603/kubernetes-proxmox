{
  pkgs,
  ...
}:

{
  env.VAULT_ADDR = "https://vault.home.phuchoang.sbs";
  env.TF_VAR_vault_addr = "https://vault.home.phuchoang.sbs";

  # https://devenv.sh/packages/
  packages = [
    pkgs.vault
    pkgs.tflint
  ];

  # https://devenv.sh/languages/
  languages.terraform = {
    enable = true;
    version = "1.6.6";
    lsp = {
      enable = true;
      package = pkgs.terraform-ls;
    };
  };

  languages.ansible = {
    enable = true;
    lsp = {
      enable = true;
      package = pkgs.ansible-language-server;
    };
  };

  enterShell = ''
    if vault token lookup >/dev/null 2>&1; then
      echo "Vault session active. Fetching Minio keys..."
      
      # We use export here because these are fetched dynamically
      export AWS_ACCESS_KEY_ID=$(vault kv get -field=access_key kv/shared/minio)
      export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secret_key kv/shared/minio)
      
      echo "AWS keys loaded into environment."
    else
      echo "Vault session inactive. Run 'vault login' to load AWS keys."
    fi
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    terraform-validate.enable = true;
    tflint.enable = true;
    ansible-lint.enable = true;
  };
}
