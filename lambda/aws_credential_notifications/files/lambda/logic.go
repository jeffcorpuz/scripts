package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"math"
	"net/http"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
)

type ServiceConfig struct {
	Session  *session.Session
	Service  *iam.IAM
	AwsUsers []AwsUser
}

type AwsUser struct {
	User       string
	PassExpire int
	KeyExpire  int
}

func NewServiceConfig() (*ServiceConfig, error) {

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := iam.New(sess)
	users := []AwsUser{}

	return &ServiceConfig{sess, svc, users}, nil
}

// List AWS Users
func (s *ServiceConfig) GetUsers() (*iam.ListUsersOutput, error) {

	input := &iam.ListUsersInput{}
	result, err := s.Service.ListUsers(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case iam.ErrCodeServiceFailureException:
				fmt.Println(iam.ErrCodeServiceFailureException, aerr.Error())
				return nil, aerr
			default:
				fmt.Println(aerr.Error())
				return nil, aerr
			}
		} else {
			fmt.Println(err.Error())
			return nil, err
		}
	}
	return result, nil
}

// Query the account password policy for the password age. Return that number of days
func (s *ServiceConfig) GetMaxPasswordAge() (int, error) {
	input := &iam.GetAccountPasswordPolicyInput{}
	result, err := s.Service.GetAccountPasswordPolicy(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case iam.ErrCodeNoSuchEntityException:
				fmt.Println(iam.ErrCodeNoSuchEntityException, aerr.Error())
				return 0, aerr
			case iam.ErrCodeServiceFailureException:
				fmt.Println(iam.ErrCodeServiceFailureException, aerr.Error())
				return 0, aerr
			default:
				fmt.Println(aerr.Error())
				return 0, aerr
			}
		} else {
			// Print the error, cast err to awserr.Error to Get the Code and
			// Message from an error.
			fmt.Println(err.Error())
			return 0, err
		}
	}
	return int(*result.PasswordPolicy.MaxPasswordAge), nil
}

// Query the amount of days until expiration using time difference
func (s *ServiceConfig) GetDaysUntilExpiration(lastChanged string, maxAge int) (int, error) {
	loc, err := time.LoadLocation("UTC")
	if err != nil {
		fmt.Println(err)
		return 0, err
	}
	now := time.Now().In(loc)

	lastChangedDate, _ := time.Parse(time.RFC3339, lastChanged)
	expires := lastChangedDate.Sub(now)

	return ((int(expires.Hours() / 24)) + maxAge), nil
}

// Request and parse to generate the credential report
func (s *ServiceConfig) GetCredentialReport() ([]map[string]string, error) {

	// Generate credential report
	input := &iam.GenerateCredentialReportInput{}
	result, err := s.Service.GenerateCredentialReport(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case iam.ErrCodeNoSuchEntityException:
				fmt.Println(iam.ErrCodeNoSuchEntityException, aerr.Error())
				return nil, aerr
			case iam.ErrCodeServiceFailureException:
				fmt.Println(iam.ErrCodeServiceFailureException, aerr.Error())
				return nil, aerr
			default:
				fmt.Println(aerr.Error())
				return nil, aerr
			}
		} else {
			fmt.Println(err.Error())
			return nil, err
		}
	}
	// Parse credential report
	c := sync.NewCond(&sync.Mutex{})
	c.L.Lock()
	for *result.State != "COMPLETE" {
		c.Wait()
		if err != nil {
			if aerr, ok := err.(awserr.Error); ok {
				switch aerr.Code() {
				case iam.ErrCodeCredentialReportNotPresentException:
					fmt.Println(iam.ErrCodeCredentialReportNotPresentException, aerr.Error())
					return nil, aerr
				case iam.ErrCodeCredentialReportNotReadyException:
					fmt.Println(iam.ErrCodeCredentialReportNotReadyException, aerr.Error())
					return nil, aerr
				default:
					fmt.Println(aerr.Error())
					return nil, aerr
				}
			} else {
				fmt.Println(err.Error())
				return nil, err
			}
		}
	}
	c.L.Unlock()

	credsInput := &iam.GetCredentialReportInput{}
	credsReport, err := s.Service.GetCredentialReport(credsInput)
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	// Create CSV
	credsReportCSV := credsReport.Content
	r := bytes.NewReader(credsReportCSV)
	credentialReport, err := csvToMap(r)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}

	return credentialReport, nil
}

// Generate a user report that returns a slice of aws users with their password and key expiration (if valid)
func (s *ServiceConfig) GenerateUserReport(iam.ListUsersOutput) ([]AwsUser, error) {
	var userReport []AwsUser

	maxAge, err := s.GetMaxPasswordAge()
	if err != nil {
		fmt.Println(err)
		return nil, err
	}
	credentialReport, err := s.GetCredentialReport()
	if err != nil {
		fmt.Println(err)
		return nil, err
	}
	// Iterate over the credential report, use the report to determine password expiration
	// Then query for access keys, and use the key creation data to determine key expiration
	for _, row := range credentialReport {
		var accessKeyExpires int

		username := row["user"]
		passwordLastChanged := row["password_last_changed"]
		// Skip IAM Users without passwords, they are service accounts
		if row["password_enabled"] != "true" {
			continue
		}
		// Process user's password expiration
		passwordExpires, err := s.GetDaysUntilExpiration(passwordLastChanged, maxAge)
		if err != nil {
			fmt.Println(err)
			return nil, err
		}
		// Process user's access key expiration
		// For IAM Users without access keys, assign nothing since they do not use the AWS SDK programmatically,
		if row["access_key_1_active"] == "true" {
			accessKeyLastRotated := row["access_key_1_last_rotated"]
			accessKeyExpires, err = s.GetDaysUntilExpiration(accessKeyLastRotated, maxAge)
			userReport = append(userReport, AwsUser{User: username, PassExpire: passwordExpires, KeyExpire: accessKeyExpires})
		} else {
			userReport = append(userReport, AwsUser{User: username, PassExpire: passwordExpires, KeyExpire: int(math.NaN())})
		}
	}

	return userReport, nil
}

// csvToMap - helper function to convert CSV record to Dictionaries using header row as keys
func csvToMap(reader io.Reader) ([]map[string]string, error) {
	r := csv.NewReader(reader)
	rows := []map[string]string{}
	var header []string
	for {
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		if header == nil {
			header = record
		} else {
			dict := map[string]string{}
			for i := range header {
				dict[header[i]] = record[i]
			}
			rows = append(rows, dict)
		}
	}

	return rows, nil
}

// SendSlackNotification will post to an 'Incoming Webook' url setup in Slack Apps.
// It accepts some text and the Slack channel is saved within Slack.
func SendSlackNotification(SlackMessage SlackRequestMessage) error {

	slackBody, err := json.Marshal(SlackMessage)
	if err != nil {
		return err
	}
	req, err := http.NewRequest(http.MethodPost, SlackWebhookURL, bytes.NewBuffer(slackBody))
	if err != nil {
		return err
	}

	req.Header.Add("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	buf := new(bytes.Buffer)
	buf.ReadFrom(resp.Body)
	if buf.String() != "ok" {
		return errors.New("Non-ok response returned from Slack")
	}

	return nil
}
