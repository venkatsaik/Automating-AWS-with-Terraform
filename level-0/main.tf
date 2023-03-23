resource "aws_s3_bucket" "terraform_remote_state" {
    bucket = "terraform-automation-remotestate"
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "terraform_remote_state"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
