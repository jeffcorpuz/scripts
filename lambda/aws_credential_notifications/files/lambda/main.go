/* Lambda Connection and Logic */

package main

import (
	"fmt"
	"math"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
)

var SlackWebhookURL = os.Getenv("SLACK_WEBHOOK_URL")

type SlackRequestMessage struct {
	Text string `json:"text"`
}

func LambdaHandler() {
	AwsConfig, err := NewServiceConfig()

	var slack SlackRequestMessage

	bcdaUsers, err := AwsConfig.GetUsers()
	if err != nil {
		fmt.Println(err)
		return
	}
	AwsConfig.AwsUsers, err = AwsConfig.GenerateUserReport(*bcdaUsers)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Enumerate through Users and prepare slack message
	for _, key := range AwsConfig.AwsUsers {
		// process password expiration
		if key.PassExpire <= 0 {
			slack = SlackRequestMessage{
				Text: fmt.Sprintf("<!here> User: %s's Access Key has expired  %d days ago", key.User, key.PassExpire*-1),
			}
			SendSlackNotification(slack)
		} else if key.PassExpire < 7 {
			slack = SlackRequestMessage{
				Text: fmt.Sprintf("<!here> User: %s's Password will expire in %d days", key.User, key.PassExpire),
			}
			SendSlackNotification(slack)
		}
		// process key expiration, ignore users that have no keys
		if key.KeyExpire == int(math.NaN()) {
			continue
		}
		if key.KeyExpire <= 0 {
			slack = SlackRequestMessage{
				Text: fmt.Sprintf("<!here> User: %s's Access Key has expired  %d days ago", key.User, key.KeyExpire*-1),
			}
			SendSlackNotification(slack)
		} else if key.KeyExpire < 7 {
			slack = SlackRequestMessage{
				Text: fmt.Sprintf("<!here> User: %s's Access Key will expire in %d days", key.User, key.KeyExpire),
			}
			SendSlackNotification(slack)
		}
	}
}

func main() {
	lambda.Start(LambdaHandler)
}
