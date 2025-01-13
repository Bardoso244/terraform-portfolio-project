terraform {
 backend "s3" {
  bucket = "bartman-websiteproject-state"
    key = "global/s3/terraform/tf-state"
    region = "eu-west-2"
    dynamodb_table = "bartman-websiteproject-state"
}
}