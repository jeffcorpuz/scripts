# Pre-Commit Hook for Terraform Formatting

## Introduction

This pre-commit hook script automates the process of ensuring that Terraform files in your Git repository are formatted properly using `terraform fmt`. This hook is designed to be used with GitHub repositories, and it helps maintain consistent code style by preventing unformatted Terraform files from being committed.

## Usage

To use this pre-commit hook in your GitHub repository, follow these steps:

### Step 1: Download the Pre-Commit Hook

Copy the contents of the provided pre-commit hook script and save it as a file named `pre-commit` in your repository's `.git/hooks/` directory.

```bash
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
```

### Step 2: Make the Pre-Commit Hook Executable

Ensure that the pre-commit hook file is executable by running the following command in your repository's root directory:

```bash
chmod +x .git/hooks/pre-commit
```

### Step 3: Commit and Push

Now, commit any changes you've made, and the pre-commit hook will automatically run before each commit. If any Terraform files are found to be unformatted, the commit will be rejected, and an error message will be displayed.

### Additional Notes

- This pre-commit hook assumes that Terraform is installed on the system where the hook is being executed. Make sure Terraform is available in the PATH.
- The script does not handle file names with spaces. Ensure that your Terraform file names adhere to this constraint.

## Contributing

If you encounter any issues or have suggestions for improvement, feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/your/repository).

Happy Terraforming!