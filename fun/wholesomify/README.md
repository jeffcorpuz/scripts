# SlackBot for Wholesome Content - Setup and Usage Guide

This guide will walk you through the process of setting up and using the SlackBot for fetching wholesome content from Reddit. The bot can be deployed on AWS Lambda and is triggered daily.

## Prerequisites

Before you begin, make sure you have the following:

- [Python](https://www.python.org/) installed on your local machine.
- [Terraform](https://www.terraform.io/) installed for deploying on AWS Lambda.
- An AWS account with the necessary permissions to create Lambda functions.
- A Reddit account with the credentials required for the bot.
- A Slack workspace where you have permission to add a bot.

## Setup

### 1. Reddit API Credentials

1. Create a Reddit App on the [Reddit Developer Portal](https://www.reddit.com/prefs/apps).
2. Obtain the `client_id`, `client_secret`, `username`, `password`, and set them as environment variables in a `.env` file in the project directory:

    ```env
    REDDITNAME=your_reddit_username
    PASSWORD=your_reddit_password
    APPID=your_reddit_app_id
    APISECRET=your_reddit_api_secret
    APPNAME=your_app_name
    LIMIT=20
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

### 3. Configure Environment Variables (Optional)

If you prefer, you can set environment variables directly in the Terraform script instead of using a `.env` file. Uncomment and modify the `environment` block in the Lambda function in the Terraform script.

## Usage

### 1. AWS Lambda

If deployed on AWS Lambda with the CloudWatch Events rule, the bot will run daily at 12:00 PM UTC. The result will be sent to the specified Slack channel.

### 2. Local Testing (Optional)

If you want to test the Lambda function locally, uncomment the last section of the Python script and run the script:

```bash
python main.py
```

## Customization

- **Reddit Source Subreddits**: You can customize the `choice` list in the `wholesomify` function to include your preferred subreddits.
  
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

Now you're all set! Enjoy the daily dose of wholesome content delivered by your SlackBot.