data "terraform_remote_state" "level-1" {
  backend = "s3"

  config = {
    bucket = "terraform-automation-remotestate"
    key    = "level-1.tfstate"
    region = "us-east-1"
  }
}



