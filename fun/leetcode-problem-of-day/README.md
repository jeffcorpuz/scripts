# LeetCode Discord Bot - Setup and Usage Guide

This guide will help you set up and use the LeetCode Discord bot, which fetches a random LeetCode question daily and sends it to a specified Discord channel. The bot can be deployed on AWS Lambda.

## Prerequisites

Before starting, ensure you have the following:

- [Python](https://www.python.org/) installed on your local machine.
- [Terraform](https://www.terraform.io/) installed for deploying on AWS Lambda.
- An AWS account with the necessary permissions to create Lambda functions.
- A Discord server where you have permission to add a bot and a webhook.
- Optionally, if you want to deploy the bot on AWS Lambda, you'll need the [AWS CLI](https://aws.amazon.com/cli/) installed and configured.

## Setup

### 1. Discord Webhook

1. Create a Discord webhook in your server. You can do this by going to Server Settings > Integrations > Webhooks.
2. Copy the webhook URL and set it as the value for the `DISCORD_WEBHOOK_URL` environment variable in a `.env` file in the project directory:

    ```env
    DISCORD_WEBHOOK_URL=your_discord_webhook_url
    ```

### 2. AWS Lambda

1. Run the following Terraform commands to set up the AWS Lambda function and CloudWatch Events rule:

    ```bash
    terraform init
    terraform plan
    ```

   Terraform will prompt you to confirm the changes. Type `yes` to proceed.

2. Run the following Terraform command to package and deploy the Lambda function:

    ```bash
    terraform apply
    ```

### 3. Local Testing (Optional)

If you want to test the Lambda function locally, run the script:

```bash
python main.py
```

## Usage

### 1. AWS Lambda

If deployed on AWS Lambda with the CloudWatch Events rule, the bot will run daily at 12:00 PM UTC. The result will be sent to the specified Discord channel through the webhook.

### 2. Local Testing

If testing locally, the bot will send a random LeetCode question URL to the specified Discord channel through the webhook.

## Customization

- **LeetCode Question Source**: You can customize the `LEETCODE_RANDOM_URL` variable to fetch questions from a different LeetCode URL if needed.

- **Deployment Configuration**: Adjust the AWS Lambda configuration in the Terraform script based on your preferences (e.g., memory size, timeout).

- **Environment Variables**: If not using the `.env` file, uncomment and modify the `environment` block in the Lambda function to set environment variables directly in the Terraform script.

## Cleanup

If you want to remove the deployed resources:

1. Run the following Terraform command:

    ```bash
    terraform destroy
    ```

2. Confirm the destruction when prompted.

3. Optionally, run:

    ```bash
    terraform clean
    ```

Now you're all set! Enjoy the daily LeetCode questions delivered by your LeetCode Discord bot.