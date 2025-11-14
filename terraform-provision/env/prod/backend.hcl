# Should be created via Vault & Generated via Github actions

access_key                  = ""
secret_key                  = ""
bucket                      = ""
key                         = ""
region                      = ""

# --- MinIO Specific Settings ---

# The URL of your MinIO server
endpoints = {
  s3 = ""
}

# Use path-style addressing (e.g., http://minio/bucket/key)
use_path_style = true

# Skip AWS-specific validation checks
skip_credentials_validation = true  # Skip AWS related checks and validations
skip_requesting_account_id = true
skip_metadata_api_check = true
skip_region_validation = true
