##Creating iam account for lambda_s3_attachment
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "lambda_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

data "aws_iam_policy" "rekognition_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}

data "aws_iam_policy" "comprehend_full_access" {
  arn = "arn:aws:iam::aws:policy/ComprehendFullAccess"
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "lambda_execution_role"{
  arn= "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_policy_attachment" "lambda_full_attachment" {
  name = "LambdaFullAccess"
  policy_arn = data.aws_iam_policy.lambda_full_access.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_rekognition_attachment" {
  name = "RekognitionFullAccess"
  policy_arn = data.aws_iam_policy.rekognition_full_access.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_comprehend_attachment" {
  name = "ComprehendFullAccess"
  policy_arn = data.aws_iam_policy.comprehend_full_access.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_s3_attachment" {
  name = "S3FullAccess"
  policy_arn = data.aws_iam_policy.s3_full_access.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "lambda_execution_role" {
  name = "LambdaExecutionrole"
  policy_arn = data.aws_iam_policy.lambda_execution_role.arn
  roles      = [aws_iam_role.lambda_role.name]
}


### Creating S3 Bucket
resource "aws_s3_bucket" "intermediate_bucket" {
  bucket = "background-check-intermediate-bucket"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.intermediate_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket" "final_bucket" {
  bucket = "background-check-final-bucket"
}
resource "aws_s3_bucket_public_access_block" "example2" {
  bucket = aws_s3_bucket.final_bucket.id

  block_public_acls   = false
  block_public_policy = false
}



### Creating the AWS Lambda Functions ###
resource "aws_lambda_function" "rekognition_lambda" {
filename                       = "rekognition.zip"
function_name                  = "solutions_hub_rekognition_lambda"
role                           = aws_iam_role.lambda_role.arn
handler                        = "rekognition.index.lambda_handler"
runtime                        = "python3.11"
timeout = 180
}

resource "aws_lambda_function" "comprehend_lambda" {
filename                       = "comprehend.zip"
function_name                  = "solutions_hub_comprehend_lambda"
role                           = aws_iam_role.lambda_role.arn
handler                        = "comprehend.index.lambda_handler"
runtime                        = "python3.11"
timeout = 180
}

resource "aws_lambda_function" "final_lambda" {
filename                       = "final_lambda.zip"
function_name                  = "solutions_hub_final_lambda"
role                           = aws_iam_role.lambda_role.arn
handler                        = "final_lambda.lambda_handler"
runtime                        = "python3.11"
timeout = 180
}
