# AWS Credential Notifications

### Description
Lambda function that notifies AWS User via a Slack Webhook that their credentials are expiring within a certain threshold through a daily CloudWatch event.

### AWS Integrations
- CloudWatch Event
  - Controls rate/cron of trigger for the function
- CloudWatch Logs
  - Function sends logs

### Configuration
**Simple**:
```shell
make 
terraform apply 
```

**Details**:
Populate Terraform TFVars:
```c
application = "aws-credentials-expiration"
name = "aws-credentials-expiration-slack-notification"
slack_webhook_url = "INSERT_WEBHOOK_HERE" # optional
schedule = "cron or rate"
```

`application` - tag for lambda function
`name` - name of the lambda function 
`slack_webhook_url` - (optional) Slack Incoming webhook, can be configured on AWS Lambda console or here
`schedule` - cron or rate

Runbook:   
1. Run `make` to build go file for [deployment](https://docs.aws.amazon.com/lambda/latest/dg/golang-package.html).
2. Run `terraform apply` to deploy function
3. If `slack_webhook_url` isn't configured in `terraform.tfvars`, go to AWS Lambda console of the function and insert true values
4. Make `test` on [console](https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions) and verify on Slack channel

**Sample Output**
```
User: XXXX's Password will expire in 5 days
User: XXXX's Password has expired 5 days ago

User: XXXX's Access Key will expire in 13 days
User: XXXX's Access Key has expired 13 days ago
```