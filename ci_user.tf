resource "aws_iam_user" "robot" {
  name = "ci-robot"
}

resource "aws_iam_user_policy_attachment" "sys_admin" {
  user       = aws_iam_user.robot.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

resource "aws_iam_user_policy_attachment" "net_admin" {
  user       = aws_iam_user.robot.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}

resource "aws_iam_user_policy_attachment" "cloudfront_full_access" {
  user       = aws_iam_user.robot.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_user_policy_attachment" "acm_full_access" {
  user       = aws_iam_user.robot.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

data "aws_iam_policy_document" "terraform_state_access" {
  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::aws-taxi-cdn-tfstate",
      "arn:aws:s3:::aws-taxi-cdn-tfstate/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "terraform_state_access" {
  policy = data.aws_iam_policy_document.terraform_state_access.json
}

resource "aws_iam_user_policy_attachment" "terraform_state_access" {
  user       = aws_iam_user.robot.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

data "aws_iam_policy_document" "robot_policy" {
  statement {
    actions   = ["ec2:GetManagedPrefixListEntries"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "robot" {
  policy = data.aws_iam_policy_document.robot_policy.json
}

resource "aws_iam_user_policy_attachment" "robot" {
  user       = aws_iam_user.robot.name
  policy_arn = aws_iam_policy.robot.arn
}
