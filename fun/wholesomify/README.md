# Wholesomify Reddit Bot - Setup and Usage Guide

This guide will help you set up and use the Wholesomify Reddit bot, which fetches wholesome content from Reddit and can be deployed on AWS Lambda.

## Prerequisites

Before getting started, make sure you have the following:

- [Python](https://www.python.org/) installed on your local machine.
- [Terraform](https://www.terraform.io/) installed for deploying on AWS Lambda.
- An AWS account with the necessary permissions to create Lambda functions.
- A [Reddit](https://www.reddit.com/) account with the credentials required for the bot.
- Optionally, if you want to deploy the bot on AWS Lambda, you'll need the [AWS CLI](https://aws.amazon.com/cli/) installed and configured.

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

### 2. Local Testing

Run the bot locally for testing:

```bash
python main.py
```

### 3. Deploy on AWS Lambda (Optional)

1. Configure AWS credentials using the AWS CLI:

    ```bash
    aws configure
    ```

2. Run Terraform commands to deploy the bot on AWS Lambda:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Usage

### 1. Local Testing

If you are testing locally, the bot will print a submission title and URL to the console.

```bash
python main.py
```

```bash
title: Your Submission Title
url: https://www.reddit.com/r/wholesomememes/
```

### 2. AWS Lambda

If deployed on AWS Lambda with the CloudWatch Events rule, the bot will run daily at 12:00 PM UTC. The result will be sent to the specified destination (e.g., Discord channel or other integration).

## Customization

- **Reddit Source Subreddits**: You can modify the `choice` list in the `wholesomify` function to include your preferred subreddits.
  
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

Now you're all set! Enjoy the wholesome content delivered by your Wholesomify Reddit bot.