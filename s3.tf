resource "aws_s3_bucket" "backend" {
  bucket = "${var.default_tags.env}-bucket"
}

# Adding because terraform does not support versioning
resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Information for bucket policy

#data "aws_iam_policy_document" "backend" {
 # statement {
  #  sid = "PublicAccess"
   # principles {
    #    type = "AWS"
     #   identifiers = ["*"]
    #}
    #actions = [
     #   "s3:*"
    #]
    #resources = [
     #   aws_s3_bucket.backend.arn, "${aws_s3_bucket.backend.arn}/*"
    #]
  #}
#}
#
#resource "aws_s3_bucket_policy" "backend" {
 # bucket = aws_s3_bucket.backend.id
  #policy = data.aws_iam_policy_document.backend.json
#}