resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.bucket_name}"
  force_destroy = true

  tags = {
      Name = "tf-state-backednd"
  }
}
