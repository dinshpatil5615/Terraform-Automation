terraform {
  backend "s3" {
    bucket = "mydev-project-terraform-sample-batch-29"
    key = "main"
    region = "ap-south-1"
    use_lockfile = "my-dynamodb-table"
  }
}
