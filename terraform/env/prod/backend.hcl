access_key                  = "terraform"
secret_key                  = "QmwRghG9X80kC%"
bucket                      = "terraform"
key                         = "dev-terraform.tfstate"
region                      = "us-east-1"

# --- MinIO Specific Settings ---

# The URL of your MinIO server
endpoints = {
  s3 = "http://10.69.1.102:9000"
}

# Use path-style addressing (e.g., http://minio/bucket/key)
use_path_style = true

# Skip AWS-specific validation checks
skip_credentials_validation = true  # Skip AWS related checks and validations
skip_requesting_account_id = true
skip_metadata_api_check = true
skip_region_validation = true
