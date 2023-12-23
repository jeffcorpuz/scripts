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