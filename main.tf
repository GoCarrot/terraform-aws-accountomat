# Copyright 2022 Teak.io, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3, < 5"
    }
  }
}

locals {
  org_prefix        = nonsensitive(data.aws_ssm_parameter.org_prefix.value)
  slugified_env     = replace(var.environment, "/[^A-Za-z0-9-_.]/", "-")
  slugified_purpose = replace(var.purpose, "/[^A-Za-z0-9-_.]/", "-")
  canonical_env     = trim(replace(lower(local.slugified_env), "/[^a-z0-9-_]/", "-"), "-")
  canonical_slug    = coalesce(var.override_canonical_slug, "${local.canonical_env}-${trim(lower(var.slug), "-")}")
  prefix            = "/${local.org_prefix}/${local.slugified_env}/${var.slug}"
  email_parts       = split("@", var.email)
  account_email     = var.generate_email ? "${local.email_parts[0]}+${local.canonical_slug}@${local.email_parts[1]}" : var.email
  account_tags      = { for key, value in var.account_tags : key => value if lookup(data.aws_default_tags.tags.tags, key, null) != value }
}

data "aws_default_tags" "tags" {}
data "aws_partition" "current" {}

data "aws_ssm_parameter" "org_prefix" {
  name = "/omat/organization_prefix"
}

resource "aws_organizations_account" "account" {
  name      = var.name
  email     = local.account_email
  parent_id = var.parent_id

  role_name = "OrganizationAccountAccessRole"

  iam_user_access_to_billing = var.iam_user_access_to_billing ? "ALLOW" : "DENY"

  tags = local.account_tags
}

locals {
  account_id     = aws_organizations_account.account.id
  admin_role_arn = "arn:${data.aws_partition.current.partition}:iam::${local.account_id}:role/${aws_organizations_account.account.role_name}"
  account_info = {
    account_id       = local.account_id
    name             = var.name
    environment      = local.slugified_env
    orig_environment = var.environment
    purpose          = local.slugified_purpose
    orig_purpose     = var.purpose
    slug             = var.slug
    prefix           = local.prefix
  }
  encoded_account_info = jsonencode(local.account_info)
}

resource "aws_ssm_parameter" "account-info" {
  name  = "${local.prefix}/account_info"
  type  = "String"
  value = local.encoded_account_info

  tags = local.account_tags
}

resource "aws_ssm_parameter" "admin-role" {
  name  = "${local.prefix}/roles/admin"
  type  = "String"
  value = local.admin_role_arn

  tags = local.account_tags
}

resource "aws_ssm_parameter" "account-registry" {
  name  = "/omat/account_registry/${local.canonical_slug}"
  type  = "String"
  value = local.encoded_account_info

  tags = local.account_tags
}

resource "aws_ssm_parameter" "org-registry" {
  name  = "/omat/org_registry/${local.slugified_purpose}/${local.slugified_env}/${local.canonical_slug}"
  type  = "String"
  value = local.encoded_account_info

  tags = local.account_tags
}
