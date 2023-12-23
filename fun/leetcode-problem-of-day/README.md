## LeetCode Discord Bot

This Python script is a simple Discord bot that fetches a random LeetCode problem and sends it to a specified Discord channel using a webhook. It is designed to run on AWS Lambda, but it can also be locally tested.

### Prerequisites

1. **Python**: Make sure you have Python installed on your system.

2. **Dependencies**: Install the required Python packages using the following command:

   ```bash
   pip install aiohttp discord.py python-dotenv
   ```

3. **Discord Webhook URL**: Set up a Discord webhook and obtain the webhook URL. Save it in a `.env` file as `DISCORD_WEBHOOK_URL`.

### Usage

#### AWS Lambda

- Deploy the script to AWS Lambda and configure it to run on a schedule using CloudWatch Events.

#### Local Testing

1. Run the script locally for testing:

   ```bash
   python script_name.py
   ```

2. Ensure that the `.env` file contains the correct `DISCORD_WEBHOOK_URL`.

### AWS Lambda Handler

The script includes an AWS Lambda handler to facilitate integration with AWS services. Modify the `lambda_handler` function as needed.

### Note

- The script uses the `discord.py` library for interacting with Discord webhooks and `aiohttp` for asynchronous HTTP requests.
- The LeetCode problem is fetched from the [LeetCode Random Question](https://leetcode.com/problems/random-one-question/) URL.
- Customize the `username` and `content` parameters in the `send_webhook` function as desired.

Feel free to adapt and extend the script to suit your needs.

# Terraform Setup for AWS Lambda Function

This Terraform configuration sets up an AWS Lambda function named "leetcode-bot" along with an IAM role necessary for its execution. The Lambda function is written in Python 3.11 and is designed to be triggered by AWS services such as API Gateway.

## Prerequisites

Before running this Terraform configuration, ensure that you have:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- Appropriate AWS credentials configured on your machine.

## Configuration

1. Clone this repository to your local machine.

   ```bash
   git clone <repository-url>
   ```

2. Navigate to the directory containing the Terraform files.

   ```bash
   cd <repository-directory>
   ```

3. Open the `main.tf` file and replace any placeholder values with your own configurations if needed.

## Running Terraform

1. Initialize your Terraform working directory.

   ```bash
   terraform init
   ```

2. Review the Terraform execution plan.

   ```bash
   terraform plan
   ```

3. Apply the Terraform configuration to create the Lambda function and IAM role.

   ```bash
   terraform apply
   ```

   Terraform will prompt you to confirm the changes. Type `yes` to proceed.

4. After the apply is complete, Terraform will output information about the created resources, including the Lambda function's ARN.

## Cleaning Up

If you want to remove the created resources:

1. Run the following command to destroy the resources.

   ```bash
   terraform destroy
   ```

   Terraform will prompt you to confirm the destruction. Type `yes` to proceed.

2. After the destroy is complete, run the following command to clean up any residual Terraform files.

   ```bash
   terraform clean
   ```

## Notes

- The IAM role (`aws_iam_role`) allows the Lambda function to be assumed by the Lambda service, enabling it to execute.

- The Lambda function (`aws_lambda_function`) is defined with the name "leetcode-bot" and is associated with the specified IAM role.

- The source code for the Lambda function is packaged in a ZIP file (`lambda.zip`) using the `archive_file` data source. The code is assumed to be located in the `files/` directory relative to the Terraform files.

Feel free to customize the Terraform configuration based on your specific requirements.