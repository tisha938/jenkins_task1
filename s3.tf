resource "aws_s3_bucket" "my_bucket" {
  bucket = "jenkin-bucket"
}


resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_owner,
    aws_s3_bucket_public_access_block.bucket_access,
  ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}



resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket =  aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*"
      }
    ]
  })
}


module "template_files" {
    source = "hashicorp/dir/template"

    base_dir = "${path.module}/web-files"
}


resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket =    aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "Bucket_files" {
  bucket =  aws_s3_bucket.my_bucket.id

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  etag = each.value.digests.md5
}