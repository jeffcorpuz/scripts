
# Jira Filler Script

## Overview

This Python script leverages the ChatGPT API to generate additional details for a Jira ticket based on its title and updates the Jira ticket with the generated details. It uses environment variables to securely store API keys and other sensitive information.

## Prerequisites

- Python 3.x installed
- `python-dotenv` library installed (`pip install python-dotenv`)
- Jira and ChatGPT API keys

## Setup

1. Clone the repository:
2. Create a `.env` file in the project directory with the following content:

   ```env
   CHATGPT_API_KEY=your_chatgpt_api_key
   JIRA_API_KEY=your_jira_api_key
   JIRA_USERNAME=your_jira_username
   JIRA_PASSWORD=your_jira_password
   JIRA_ENDPOINT=https://your-jira-instance/rest/api/3/issue/
   ```

   Replace `your_chatgpt_api_key`, `your_jira_api_key`, `your_jira_username`, `your_jira_password`, and the Jira endpoint with your actual API keys and credentials.

3. Install required dependencies:

   ```bash
   pip install -r requirements.txt
   ```

## Usage

Run the script and follow the prompts:

```bash
python jira_filler.py
```

The script will ask you to provide the Jira ticket URL. It will then extract the issue key and title, generate additional details using ChatGPT, and update the Jira ticket.

## Examples

### Example 1: Updating Jira Ticket from URL

```bash
Enter the Jira ticket URL: https://your-jira-instance/browse/PROJECT-123
```

Output:

```
Issue Key: PROJECT-123
Title: Title of the Jira Ticket
Jira ticket PROJECT-123 updated successfully.
```

### Example 2: Invalid Jira URL

```bash
Enter the Jira ticket URL: https://invalid-jira-url
```

Output:

```
Invalid Jira URL format.
```

---

This example assumes a basic project structure with a `.env` file for environment variables and a simple command-line interface.