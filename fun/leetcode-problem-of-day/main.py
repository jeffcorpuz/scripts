import requests
import discord
import asyncio
import aiohttp
import os

from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Discord Webhook URL
WEBHOOK_URL: str | None = os.getenv(key="DISCORD_WEBHOOK_URL")

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

async def main() -> None:
    random_question: str = get_random_question()
    await send_webhook(message=random_question)

if __name__ == "__main__":
    asyncio.run(main=main())
