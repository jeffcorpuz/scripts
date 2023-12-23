# Running Terraform for AWS Lambda Deployment

This Terraform configuration deploys an AWS Lambda function using a Docker image.

## Prerequisites

Make sure you have the following prerequisites installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- Docker (if creating a custom Docker image)

## Getting Started

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Open a terminal and navigate to the directory containing your Terraform code.

3. Create a `terraform.tfvars` file to provide values for the required variables:

   ```hcl
   vpc_name            = "your-vpc-name"
   security_group_name = "your-security-group-name"
   name                = "your-lambda-function-name"
   image_uri           = "your-docker-image-uri"
   ```

   Replace placeholders like `your-vpc-name`, `your-security-group-name`, `your-lambda-function-name`, and `your-docker-image-uri` with your specific values.

4. Run the following commands to initialize and apply the Terraform configuration:

   ```bash
   terraform init
   terraform apply
   ```

5. Review the changes and type `yes` to apply the changes.

## Clean Up

To destroy the resources created by Terraform:

```bash
terraform destroy
```

Review the changes and type `yes` to destroy the resources.

**Note:** Be cautious when destroying resources, as it will permanently delete them.

## Additional Notes

- The provided Terraform code assumes that you have already built and pushed the Docker image specified in `image_uri`.

- Verify the IAM roles, policies, and permissions to ensure they meet your security requirements.

- Customize the Terraform configuration according to your project's specific needs.

For more information about Terraform, refer to the [Terraform documentation](https://www.terraform.io/docs/index.html).

**Important:** Always follow best practices for managing sensitive information such as AWS credentials and Docker images.