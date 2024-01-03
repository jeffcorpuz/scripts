import os
from dotenv import load_dotenv
import requests
import re

# Load environment variables from .env file
load_dotenv()

def get_chatgpt_response(prompt):
    chatgpt_api_key = os.getenv("CHATGPT_API_KEY")
    chatgpt_endpoint = "https://api.openai.com/v1/chat/completions"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {chatgpt_api_key}",
    }

    data = {
        "model": "text-davinci-002",
        "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": prompt}],
    }

    response = requests.post(chatgpt_endpoint, json=data, headers=headers)
    return response.json()["choices"][0]["message"]["content"]

def update_jira_ticket(issue_key, details):
    jira_api_key = os.getenv("JIRA_API_KEY")
    jira_username = os.getenv("JIRA_USERNAME")
    jira_password = os.getenv("JIRA_PASSWORD")
    jira_endpoint = os.getenv("JIRA_ENDPOINT") + issue_key

    headers = {
        "Content-Type": "application/json",
    }

    auth = (jira_username, jira_password)

    data = {
        "fields": {
            "description": details,
        }
    }

    response = requests.put(jira_endpoint, json=data, headers=headers, auth=auth)

    if response.status_code == 204:
        print(f"Jira ticket {issue_key} updated successfully.")
    else:
        print(f"Failed to update Jira ticket {issue_key}. Status code: {response.status_code}")

def extract_issue_key_and_title(jira_url):
    # Example Jira URL: https://your-jira-instance/browse/PROJECT-123
    match = re.match(r"https?://.*?/browse/([A-Z]+-\d+)", jira_url, re.IGNORECASE)
    if match:
        return match.group(1), get_chatgpt_response(match.group(1))
    else:
        print("Invalid Jira URL format.")
        return None, None

def main():
    jira_url = input("Enter the Jira ticket URL: ")
    issue_key, title = extract_issue_key_and_title(jira_url)

    if issue_key and title:
        print(f"Issue Key: {issue_key}")
        print(f"Title: {title}")

        # Get additional details from ChatGPT based on the title
        details = get_chatgpt_response(title)

        # Update Jira ticket with the generated details
        update_jira_ticket(issue_key, details)

if __name__ == "__main__":
    main()
