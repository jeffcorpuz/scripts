import requests
import discord

# Discord Webhook URL
WEBHOOK_URL = "https://discord.com/api/webhooks/1187825630339944652/uk1TEq-Ikr2zyHnni7YFJjuruxp2N3CvY9hSKCeSKe7KXverLoApCgiAm4DEBF2_1T5k"

# LeetCode Random Question URL
LEETCODE_RANDOM_URL = "https://leetcode.com/problems/random-one-question/"

def get_random_question():
    response = requests.get(LEETCODE_RANDOM_URL)
    return response.url

def send_webhook(message):
    webhook = discord.Webhook.from_url(WEBHOOK_URL, adapter=discord.RequestsWebhookAdapter())
    webhook.send(content=message)

def main():
    random_question = get_random_question()
    send_webhook(random_question)

if __name__ == "__main__":
    main()