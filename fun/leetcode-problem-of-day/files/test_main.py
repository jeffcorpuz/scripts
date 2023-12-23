import unittest
import discord
import requests

from unittest.mock import MagicMock, patch
from main import get_random_question, send_webhook, main

class TestLeetCodeBot(unittest.TestCase):

    @patch('main.requests.get')
    def test_get_random_question_valid_response(self, mock_get) -> None:
        mock_get.return_value.url = "https://leetcode.com/problems/test-problem/"
        result: str = get_random_question()
        self.assertEqual(first=result, second="https://leetcode.com/problems/test-problem/")

    @patch('main.requests.get')
    def test_get_random_question_empty_response(self, mock_get) -> None:
        mock_get.return_value.url = ""
        result: str = get_random_question()
        self.assertEqual(first=result, second="")

    @patch('main.requests.get')
    def test_get_random_question_network_error(self, mock_get) -> None:
        mock_get.side_effect = requests.RequestException("Mocked network error")
        result: str = get_random_question()
        self.assertEqual(result, "")

    @patch('main.discord.Webhook.from_url')
    @patch('main.aiohttp.ClientSession')
    async def test_send_webhook_valid_url(self, mock_session, mock_webhook) -> None:
        mock_webhook.return_value.send.return_value = MagicMock()
        await send_webhook(message="Test message")
        mock_webhook.return_value.send.assert_called_once_with(content="Test message", username='leetcode-bot')

    @patch('main.discord.Webhook.from_url')
    @patch('main.aiohttp.ClientSession')
    async def test_send_webhook_invalid_url(self, mock_session, mock_webhook) -> None:
        mock_webhook.side_effect = discord.InvalidArgument("Mocked invalid URL error")
        with self.assertRaises(discord.InvalidArgument):
            await send_webhook("Test message")

    @patch('main.get_random_question')
    @patch('main.send_webhook')
    @patch('main.asyncio.run')
    def test_main(self, mock_run, mock_send_webhook, mock_get_random_question) -> None:
        mock_get_random_question.return_value = "https://leetcode.com/problems/test-problem/"
        main()
        mock_send_webhook.assert_called_once_with(message="https://leetcode.com/problems/test-problem/")

if __name__ == '__main__':
    unittest.main()
