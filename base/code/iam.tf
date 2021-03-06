data "aws_iam_policy_document" "ec2_assume_policy" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "ec2_generic" {
  name = "${var.region_name}-${var.env_designator}-ec2-generic-role"
  path = "/"

  #description        = "Based on webapp AmazonSSMRoleForInstancesQuickSetup"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_policy.json
}


resource "aws_iam_instance_profile" "ec2_generic" {
  name        = "${var.region_name}-${var.env_designator}-ec2-generic-profile"
  role        = aws_iam_role.ec2_generic.name
}

resource "aws_iam_role_policy_attachment" "ec2_generic" {
  role       = aws_iam_role.ec2_generic.name
  policy_arn = aws_iam_policy.ec2_generic.arn
}

resource "aws_iam_policy" "ec2_generic" {
  name        = "${var.region_name}-${var.env_designator}-ec2-generic-policy"
  path        = "/"
  description = "Policy forwebapp EC2 instance"

  policy = data.aws_iam_policy_document.ec2_generic.json
}

data "aws_iam_policy_document" "ec2_generic" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "cloudwatch:*",
      "ssm:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/UserName"
      values   = ["&{aws:username}"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

}

# AWS Policies
# ++++++++++++
data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "CloudWatchFullAccess" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Policy attachments
# ++++++++++++++++++
resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM" {
  role       = aws_iam_role.ec2_generic.name
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforSSM.arn
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.ec2_generic.name
  policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}

resource "aws_iam_role_policy_attachment" "CloudWatchFullAccess" {
  role       = aws_iam_role.ec2_generic.name
  policy_arn = data.aws_iam_policy.CloudWatchFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ec2_generic.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}