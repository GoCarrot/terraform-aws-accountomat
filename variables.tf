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

variable "name" {
  description = <<-EOT
  The human readable name of the account. This should be unique across your
  organization, but this is not enforced. Will who up in billing reports.
EOT
  type        = string
  nullable    = false
}

variable "environment" {
  description = <<-EOT
  This should correspond to a phase in your software development lifecycle,
  e.g. development, production, stage, etc. Environment is used by other
  *omat services with attributed based access control to restrict mixing of
  SDLC stages.
EOT
  type        = string
  nullable    = false

  validation {
    condition     = !can(regex("^(?i:omat)", var.environment))
    error_message = "The environment may not start with omat."
  }
}

variable "purpose" {
  description = <<-EOT
  What is this account for? This should be high level,
  e.g. workload, CI/CD, sandbox, etc.
EOT
  type        = string
  nullable    = false

  validation {
    condition     = !can(regex("^(?i:omat)", var.purpose))
    error_message = "The purpose may not start with omat."
  }
}

variable "slug" {
  description = <<-EOT
  This must be unique in the environment, and must match [A-Za-z0-9-._]+.
  Used for SSM parameter naming and programatic account discovery.
EOT
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-._]+$", var.slug))
    error_message = "The slug must match /^[A-Za-z0-9-._]+$/."
  }

  validation {
    condition     = !can(regex("^(?i:omat)", var.slug))
    error_message = "The slug may not start with omat."
  }
}

variable "email" {
  description = <<-EOT
  This must be a globally unique email. This email will receive account alerts
  and be capable of resetting the account's root password and logging in as
  root.

  If generate_email is true, Accountomat will generate an email address for
  the account based off of email, in the form <local_part>+<canonical_slug>@<domain>
EOT
  type        = string
  nullable    = false
}

variable "generate_email" {
  description = <<-EOT
  Accountomat will generate an email address for
  the account based off of email, in the form <local_part>+<canonical_slug>@<domain>
EOT
  type        = bool
  nullable    = false
  default     = true
}

variable "parent_id" {
  description = <<-EOT
  Parent Organizational Unit ID or Root ID for the account.
EOT
  type        = string
  nullable    = false
}

variable "account_tags" {
  description = "Additional tags to apply to the account resource. Will be deduplicated with default tags."
  type        = map(string)
  default     = {}
}

variable "iam_user_access_to_billing" {
  description = <<-EOT
  If true, the new account enables IAM users to access account billing information
  if they have the correct permissions.
EOT
  type        = bool
  nullable    = false
  default     = false
}

variable "override_canonical_slug" {
  description = <<-EOT
  Override the generated canonical slug with your own select. Must be globally unique!
EOT
  type        = string
  nullable    = true
  default     = null
}
