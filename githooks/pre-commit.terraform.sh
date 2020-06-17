#!/usr/bin/env bash
# git terraform fmt pre-commit hook
#
# This script does not handle file names that contain spaces.

terraformfiles=$(git diff --cached --name-only --diff-filter=ACM | grep '.tf$')
[ -z "$terraformfiles" ] && exit 0

unformatted=$(terraform fmt -recursive $terraformfiles)
[ -z "$unformatted" ] && exit 0

# Some files are not terraform fmt'd. Print message and fail.

echo >&2 "Terraform files must be formatted with terraform fmt. Please run:"
for fn in $unformatted; do
	echo >&2 "  terraform fmt -recursive"
done

exit 1
 
