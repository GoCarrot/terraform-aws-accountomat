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

output "organization_prefix" {
  description = "The determed organization prefix for all SSM parameters."
  value       = local.org_prefix
}

output "name" {
  description = <<-EOT
  The human readable name of the account. This should be unique across your
  organization, but this is not enforced. Will who up in billing reports.
EOT
  value       = var.name
}

output "environment" {
  description = <<-EOT
  This should correspond to a phase in your software development lifecycle,
  e.g. development, production, stage, etc. Environment is used by other
  *omat services with attributed based access control to restrict mixing of
  SDLC stages.
EOT
  value       = var.environment
}

output "slug_environment" {
  description = <<-EOT
  Environment, with all characters not matching \[A-Za-z0-9-.\_\] converted to -
EOT
  value       = local.slugified_env
}

output "purpose" {
  description = <<-EOT
  What is this account for? This should be high level,
  e.g. workload, CI/CD, sandbox, etc.
EOT
  value       = var.purpose
}

output "purpose_slug" {
  description = <<-EOT
  Purpose, with all characters not matching \[A-Za-z0-9-.\_\] converted to -
EOT
  value       = local.slugified_purpose
}

output "slug" {
  description = <<-EOT
  This must be unique in the environment, and must match [A-Za-z0-9-._]+.
  Used for SSM parameter naming and programatic account discovery.
EOT
  value       = var.slug
}

output "parent_id" {
  description = <<-EOT
  Parent Organizational Unit ID or Root ID for the account.
EOT
  value       = var.parent_id
}

output "iam_user_access_to_billing" {
  description = <<-EOT
  If true, the new account enables IAM users to access account billing information
  if they have the correct permissions.
EOT
  value       = var.iam_user_access_to_billing
}

output "email" {
  description = "The email address for the root user of the account."
  value       = local.account_email
}

output "canonical_slug" {
  description = <<-EOT
  Globally unique canonical slug for the account. General information for the account will be
  published under /omat/account_registry/<canonical_slug> and
  /omat/org_registry/<environment_slug>/<purpose_slug>/<canonical_slug>
EOT
  value       = local.canonical_slug
}

output "account_info" {
  description = <<-EOT
  A map of
  {
    account_id: ID of the created account
    name: <name>,
    environment: <environment_slug>
    orig_environment: <environment>
    purpose: <purpose_slug>
    orig_purpose: <purpose>
    slug: <slug>
    prefix: /<organization_prefix>/<environment_slug>/<slug>
  }

  This data is published under /omat/account_registry/<canonical_slug> and
  /omat/org_registry/<environment_slug>/<purpose_slug>/<canonical_slug> encoded
  as JSON.
EOT
  value       = local.account_info
}

output "prefix" {
  description = "The SSM parameter prefix for all account configuration."
  value       = local.prefix
}
