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
      version = ">= 3, < 6"
    }
  }

  required_version = ">= 1.1"
}

locals {
  slugified_env  = replace(var.environment, "/[^A-Za-z0-9-_.]/", "-")
  canonical_env  = trim(replace(lower(local.slugified_env), "/[^a-z0-9-_]/", "-"), "-")
  canonical_slug = coalesce(var.override_canonical_slug, "${local.canonical_env}-${trim(lower(var.slug), "-")}")
  email_parts    = split("@", var.email)
  account_email  = var.generate_email ? "${local.email_parts[0]}+${local.canonical_slug}@${local.email_parts[1]}" : var.email
  account_tags   = { for key, value in var.account_tags : key => value if lookup(data.aws_default_tags.tags.tags, key, null) != value }
}

data "aws_default_tags" "tags" {}

resource "aws_organizations_account" "account" {
  name      = var.name
  email     = local.account_email
  parent_id = var.parent_id

  role_name = "OrganizationAccountAccessRole"

  iam_user_access_to_billing = var.iam_user_access_to_billing ? "ALLOW" : "DENY"

  tags = local.account_tags
}

module "parameters" {
  source = "./modules/parameters"

  account_id      = aws_organizations_account.account.id
  admin_role_name = aws_organizations_account.account.role_name
  name            = var.name
  environment     = var.environment
  purpose         = var.purpose
  slug            = var.slug
  account_tags    = local.account_tags

  override_canonical_slug = var.override_canonical_slug
}

moved {
  from = aws_ssm_parameter.account-info
  to   = module.parameters.aws_ssm_parameter.account-info
}

moved {
  from = aws_ssm_parameter.admin-role
  to   = module.parameters.aws_ssm_parameter.admin-role
}

moved {
  from = aws_ssm_parameter.account-registry
  to   = module.parameters.aws_ssm_parameter.account-registry
}

moved {
  from = aws_ssm_parameter.org-registry
  to   = module.parameters.aws_ssm_parameter.org-registry
}
