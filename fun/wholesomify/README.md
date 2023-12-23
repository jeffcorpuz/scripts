# Wholesome Reddit Bot

This is a simple Python script that uses the PRAW (Python Reddit API Wrapper) library to fetch a random wholesome submission from Reddit. The script is designed to be used as an AWS Lambda function, but it can also be tested locally.

## Prerequisites

Before running the script, make sure you have the following installed:

- Python 3.x
- PRAW library (`pip install praw`)
- `python-dotenv` library (`pip install python-dotenv`)

## Setup

1. Clone this repository to your local machine.

   ```bash
   git clone <repository-url>
   ```

2. Install the required dependencies.

   ```bash
   pip install -r requirements.txt
   ```

3. Create a `.env` file in the root directory of the project with the following content:

   ```env
   REDDITNAME=your_reddit_username
   PASSWORD=your_reddit_password
   APPID=your_reddit_app_id
   APISECRET=your_reddit_api_secret
   APPNAME=your_app_name
   LIMIT=20
   ```

   Replace the placeholder values with your Reddit credentials and application information.

## Usage

### AWS Lambda Function

1. Deploy the script as an AWS Lambda function by uploading a ZIP file containing the script and its dependencies.

2. Set up environment variables in the Lambda function with the same keys as in the `.env` file.

3. Configure an API Gateway trigger for the Lambda function if you want to expose it as an API endpoint.

### Local Testing

Run the script locally for testing:

```bash
python main.py
```

## Note

- The script fetches a random submission from one of the specified subreddits (`wholesomememes`, `aww`, `EyeBleach`) in the `choice` list.

- Adjust the `LIMIT` variable in the `.env` file to control the number of submissions to consider.

- The script prints the title and URL of the fetched submission when run locally.

Feel free to customize the script further based on your requirements.

# Terraform Configuration for Wholesomify Lambda Function

This Terraform configuration sets up an AWS Lambda function named "wholesomify" and, optionally, schedules it to run daily using AWS CloudWatch Events. The Lambda function is assigned an IAM role that allows it to be executed by AWS Lambda.

## Prerequisites

Before using this Terraform configuration, ensure that you have:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- AWS credentials configured on your machine.

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

3. Apply the Terraform configuration to create the Lambda function, IAM role, and, optionally, the CloudWatch Events rule.

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

- The Lambda function (`aws_lambda_function`) is defined with the name "wholesomify" and is associated with the specified IAM role.

- The CloudWatch Events rule (`aws_cloudwatch_event_rule`) and target (`aws_cloudwatch_event_target`) can be uncommented if you want to trigger the Lambda function daily at 12:00 PM UTC. Adjust the `schedule_expression` as needed.

- Optionally, you can configure environment variables for the Lambda function by uncommenting the `environment` block and providing appropriate values. Alternatively, you can use a `.env` file for sensitive information.

Feel free to customize the Terraform configuration based on your specific requirements.