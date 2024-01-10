## 0.0.4

ENHANCEMENTS:

* Store account information by account id. This will allow AWS providers to determine what account they are in without needing a canonical account slug passed in.

## 0.0.3

ENHANCEMENTS:

* Permit AWS provider v5.

## 0.0.2

BREAKING CHANGES:

* The output `slug_environment` has been renamed to `environment_slug`
* Terraform 1.1+ is now required

ENHANCEMENTS:

* Provide modules/parameters to allow configuring just omat discoverability parameters for existing accounts.

## 0.0.1

Initial release.
