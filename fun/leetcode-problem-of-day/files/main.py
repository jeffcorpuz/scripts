import os
import requests
import asyncio
import aiohttp
import discord

from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Discord Webhook URL
WEBHOOK_URL: str | None = os.getenv("DISCORD_WEBHOOK_URL")

# LeetCode Random Question URL
LEETCODE_RANDOM_URL = "https://leetcode.com/problems/random-one-question/"

# get a random problem of the day
def get_random_question() -> str:
    response = requests.get(url=LEETCODE_RANDOM_URL)
    return response.url

async def send_webhook(message) -> None:
    async with aiohttp.ClientSession() as session:
        webhook = discord.Webhook.from_url(WEBHOOK_URL, session=session)
        await webhook.send(content=message, username='leetcode-bot')

async def main(event, context) -> None:
    random_question: str = get_random_question()
    await send_webhook(message=random_question)

# AWS Lambda handler
def lambda_handler(event, context):
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(main(event, context))

if __name__ == "__main__":
    # For local testing
    asyncio.run(main(None, None))
