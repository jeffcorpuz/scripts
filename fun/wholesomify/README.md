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
python script_name.py
```

Make sure to replace `script_name.py` with the actual name of your script.

## Note

- The script fetches a random submission from one of the specified subreddits (`wholesomememes`, `aww`, `EyeBleach`) in the `choice` list.

- Adjust the `LIMIT` variable in the `.env` file to control the number of submissions to consider.

- The script prints the title and URL of the fetched submission when run locally.

Feel free to customize the script further based on your requirements.