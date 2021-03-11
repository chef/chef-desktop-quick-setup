# Let terraform create the policy document and use the JSON generate from it.
# Creating a policy document file manually and using its content is somewhat supported, but not recommended.
data "aws_iam_policy_document" "role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow" #This is the default value, but mentioned here to avoid ambiguity.
  }
}

# Create IAM role
resource "aws_iam_role" "s3_access_role" {
  name = "cdqs-s3-access-iam-role"
  assume_role_policy = data.aws_iam_policy_document.role_policy_document.json
}

# Let terraform create the policy document and use the JSON generate from it.
# Creating a policy document file manually and using its content is somewhat supported, but not recommended.
data "aws_iam_policy_document" "policy_document" {
  statement {
    # Allows all actions on s3
    actions = ["s3:*"]
    resources = ["*"]
    effect = "Allow" #This is the default value, but mentioned here to avoid ambiguity.
  }
}

# Create IAM policy
resource "aws_iam_policy" "access_policy" {
  name = "cdqs-access-policy"
  policy = data.aws_iam_policy_document.policy_document.json
}

# Assign the policy to role.
resource "aws_iam_policy_attachment" "access_policy_attachment" {
  name = "cdqs-access-policy-attachment"
  roles = [ aws_iam_role.s3_access_role.name ]
  policy_arn = aws_iam_policy.access_policy.arn
}

# Create instance profile and export as output to be attached to the ec2 instances for virtual nodes.
resource "aws_iam_instance_profile" "instance_profile" {
  depends_on = [ aws_iam_policy_attachment.access_policy_attachment ]
  name = "cdqs-instance-profile"
  role = aws_iam_role.s3_access_role.name
}