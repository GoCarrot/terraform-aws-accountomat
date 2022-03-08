# Accountomat

Accountomat provisions an AWS account inside of an [AWS Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) and creates a set of [Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) parameters to aid in account discovery.

## Prerequisites

* Accountomat must be used in your root AWS account with a preexisting AWS Organization.
* Accountomat requires an existing SSM parameter in the root account and current provider region at /omat/organization_prefix. Accountomat will prefix SSM parameters with the contents of this SSM parameter. For example, if the contents of /omat/organization_prefix are teak, Accontomat will create SSM parameters named /teak/...

## Account attributes

Accountomat requires that each account have the following

* *Name*. This should be unique across your entire organization and should succinctly identify the account for the benefit of humans. The name of the account will appear in your billing reports.
* *Environment*. This should correspond to a phase in your software development lifecycle, e.g. development, production, stage, etc. Environment is used by other \*omat services with attributed based access control to restrict mixing of SDLC stages (no deploying development builds straight to prod.)
* *Purpose*. What is this account for? This should be high level, e.g. workload, CI/CD, sandbox, etc.
* *Slug*. This must be unique in the Environment, and must match \[A-Za-z0-9-.\_\]+
* *Email*. This must be globally unique.

Please note that Accountomat reserves the prefix `omat` for environment, purpose, and slug, and none of this attributes may start with `omat`.

## Vended attributes

* *Canonical Slug*. Accountomat will assign a canonical slug for your account, which will match \[a-z0-9-\_\]+ and be globally unique within your organization.

## SSM Parameters

The names below use the following substitution variables

* {organization_prefix} is the value at /omat/organization_prefix
* {canonical_slug} is the Accountomat assigned canonical slug
* {slug} is the given slug
* {environment} is the given environment, with all characters not matching \[A-Za-z0-9-.\_\] converted to -
* {purpose} is the given purpose, with all characters not matching \[A-Za-z0-9-.\_\] converted to -
* {prefix} is /{organization_prefix}/{environment}/{slug}

Accountomat will manage the following SSM parameters

* /{prefix}/roles/admin: ARN of an IAM role which can administer the account
* /omat/account_registry/{canonical_slug}: JSON document containing
  * account_id: ID of the created account
  * name: Given name of the account
  * environment: {environment}
  * orig_environment: Environment as given, without conversion
  * purpose: {purpose}
  * orig_purpose: Purpose as given, without conversion
  * slug: {slug}
* /omat/org_registry/{purpose}/{environment}/{canonical_slug}: JSON document identical to /omat/account_registry/{canonical_slug}

## Usage

```hcl
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

# Organizational unit that all Sandbox accounts should be under.
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = aws_organizations_organization.org.roots[0].id
}

module "sandbox-0001" {
  source = "GoCarrot/accountomat/aws"

  name        = "Sandbox Acct 0001"
  environment = "development"
  purpose     = "Sandbox"
  slug        = "sandbox-0001"
  email       = "admin@example.com"
  parent_id   = aws_organizations_organizational_unit.sandbox.id
}
```

## Updating Previously Created Accounts

You may need to manually modify the state file in order to move a previous account into accountomat. The core problem is the `iam_user_access_to_billing` attribute, which Terraform does not require and defaults to null. Accountomat will always set this attribute, and Terraform considers modifying this attribute to require destroying and recreating the resource. However, AWS account resources cannot be easily destroyed. To rectify this, before migrating the account into an accountomat module

1. If the aws_organizations_account resource does not have `iam_user_access_to_billing` set, set it to `"ALLOW"`
2. Run `$ terraform state pull > state.json`
3. Modify the stored state for the aws_organizations_account resource to update `iam_user_access_to_billing` to `"ALLOW"`
4. Increment the `"serial"` attribute of the state file.
5. Run `$ terraform state push state.json`

This will ensure that Terraform sees the `iam_user_access_to_billing` attribute as `"ALLOW"` instead of `null`, and Terraform will no longer attempt to destroy and recreate the account.

To migrate the account into the module, run `terraform state mv aws_organizations_account.<name> module.<module_name>.aws_organizations_account.account`.
