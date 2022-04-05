resource "aws_iam_user" "this" {
  count = var.create_user ? 1 : 0

  name                 = var.name
  path                 = var.path
  force_destroy        = var.force_destroy
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_user_login_profile" "this" {
  count = var.create_user && var.create_iam_user_login_profile ? 1 : 0

  user                    = aws_iam_user.this[0].name
  pgp_key                 = var.pgp_key
  password_length         = var.password_length
  password_reset_required = var.password_reset_required
}

resource "aws_iam_access_key" "this" {
  count = var.create_user && var.create_iam_access_key && var.pgp_key != "" ? 1 : 0

  user    = aws_iam_user.this[0].name
  pgp_key = var.pgp_key
}

resource "aws_iam_access_key" "this_no_pgp" {
  count = var.create_user && var.create_iam_access_key && var.pgp_key == "" ? 1 : 0

  user = aws_iam_user.this[0].name
}

resource "aws_iam_user_ssh_key" "this" {
  count = var.create_user && var.upload_iam_user_ssh_key ? 1 : 0

  username   = aws_iam_user.this[0].name
  encoding   = var.ssh_key_encoding
  public_key = var.ssh_public_key
}

resource "aws_iam_policy" "custom" {
  count = length(var.custom_iam_policies)

  name        = var.custom_iam_policies[count.index]["name"]
  policy      = var.custom_iam_policies[count.index]["policy"]
  description = lookup(var.custom_iam_policies[count.index], "description", null)

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "custom" {
  count = length(var.custom_iam_policies)

  user = aws_iam_user.this.iam_user_name
  policy_arn = element(aws_iam_policy.custom.*.arn, count.index)
}
