# GitHub Actions Workflow: Build and Deploy Lambda Function

This GitHub Actions workflow automates the build and deployment of an AWS Lambda function using Docker and Terraform.

## Workflow Overview

This workflow is triggered on each push to the `main` branch. It performs the following steps:

1. **Checkout Repository:**
   - Uses GitHub Actions to clone the repository.

2. **Setup AWS CLI:**
   - Configures AWS CLI with the provided access key ID and secret access key.
   - Specifies the AWS region.

3. **Login to Amazon ECR:**
   - Uses the official AWS ECR login action to authenticate Docker with Amazon ECR.

4. **Setup Terraform:**
   - Configures Terraform with the specified version (1.6.6 in this case).

5. **Build, Tag, and Push Docker Image to Amazon ECR:**
   - Builds a Docker image from the repository.
   - Tags the image with the latest commit SHA.
   - Pushes the image to the specified Amazon ECR repository.

6. **Terraform Initialization:**
   - Initializes Terraform in the working directory.

7. **Terraform Plan:**
   - Runs `terraform plan` to preview the changes to be applied.
   - Continues on error to allow further steps to run.

8. **Terraform Apply:**
   - Applies the Terraform configuration, deploying the Lambda function.
   - Passes the Docker image URI as a variable.

## Prerequisites

Before running this workflow, ensure the following:

- **AWS Credentials:**
  - Set up AWS access key ID and secret access key as GitHub secrets (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

- **Terraform Configuration:**
  - Have a Terraform configuration in your repository.

- **Docker Image:**
  - The Dockerfile in your repository should build a valid Docker image for your Lambda function.

## Usage

1. **Clone Repository:**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Set AWS Credentials:**
   - Add AWS access key ID and secret access key as GitHub secrets.

3. **Run Workflow:**
   - Push changes to the `main` branch to trigger the workflow.

4. **Monitor Workflow:**
   - Check the GitHub Actions tab to monitor the progress of the workflow.

## Notes

- **Customization:**
  - Modify the `REPOSITORY_NAME` and other variables in the `env` section according to your repository.

- **Security:**
  - Always follow security best practices, especially when dealing with AWS credentials and Docker images.

- **Terraform Variables:**
  - Adjust Terraform variable values in the `terraform apply` step if needed.

- **Destruction:**
  - The workflow does not include a destruction step. Be cautious when applying changes.

For more information, refer to the Terraform and AWS documentation.

**Important:** This README is a general guide. Customize it based on your specific project structure and requirements.