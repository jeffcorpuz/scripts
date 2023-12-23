# Lambda Connection and Logic

This set of files comprises a Lambda function written in Go that interacts with the AWS SDK to analyze and report on AWS IAM user credentials. The Lambda function is designed to run on a scheduled basis and identify users with expiring passwords or access keys, sending notifications to a specified Slack channel.

## Lambda Handler (`main.go`)

### Overview

The `LambdaHandler` function is the main entry point for the Lambda function. It utilizes the AWS SDK for IAM to retrieve user information, generate a user report, and send Slack notifications for users with expiring credentials.

### Dependencies

- AWS SDK for IAM: The Lambda function uses the `github.com/aws/aws-sdk-go/service/iam` package to interact with the AWS Identity and Access Management (IAM) service.

### Usage

The Lambda function is triggered automatically based on a schedule. Ensure that the Lambda execution role has the necessary IAM permissions to list users, get account password policy, generate credential reports, and send notifications to Slack.

## Service Configuration (`service.go`)

### Overview

The `ServiceConfig` struct encapsulates the AWS SDK session, IAM service, and a slice of `AwsUser` objects. It provides methods to interact with the AWS SDK for IAM, query user information, and generate user reports.

### Dependencies

- AWS SDK for IAM: The `github.com/aws/aws-sdk-go/service/iam` package is used to create an AWS SDK session and interact with IAM.

### Usage

Create an instance of `ServiceConfig` using the `NewServiceConfig` function, which initializes the AWS SDK session and IAM service. Use the provided methods to query IAM users, get the maximum password age, get days until password expiration, generate credential reports, and generate user reports.

## Sending Slack Notifications (`service.go`)

### Overview

The `SendSlackNotification` function sends notifications to a Slack channel using an incoming webhook URL. It accepts a `SlackRequestMessage` containing the text of the notification.

### Dependencies

- HTTP Package: The `net/http` package is used to make HTTP requests to the Slack webhook URL.
- JSON Package: The `encoding/json` package is used to marshal the `SlackRequestMessage` into JSON format.

### Usage

Configure the `SlackWebhookURL` environment variable with the appropriate Slack incoming webhook URL. Call the `SendSlackNotification` function with a `SlackRequestMessage` to send notifications to the specified Slack channel.

## Additional Notes

- The Lambda function assumes that environment variables are correctly set, including `SLACK_WEBHOOK_URL` for Slack integration.
- Ensure that the Lambda execution role has the necessary IAM permissions to interact with IAM, generate credential reports, and send notifications to Slack.
