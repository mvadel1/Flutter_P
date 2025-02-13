import requests
import random
import string
from flask import current_app

class ChinguisoftService:
    def __init__(self, validation_key, validation_token, app_name):
        self.validation_key = validation_key
        self.validation_token = validation_token
        self.app_name = app_name
        self.api_url = f"https://chinguisoft.com/api/sms/validation/{self.validation_key}"

    def send_validation_sms(self, phone, lang):
        headers = {
            'Validation-token': self.validation_token,
            'Content-Type': 'application/json'
        }
        payload = {
            'phone': phone,
            'lang': lang
        }
        try:
            response = requests.post(self.api_url, headers=headers, json=payload)
            data = response.json()

            if response.status_code == 200:
                code = data.get('code')
                if not code:
                    code = ''.join(random.choices(string.digits, k=6))
                else:
                    code = str(code)  

                return {
                    'success': True,
                    'code': code,
                    'balance': data.get('balance', 0)
                }
            else:
                return {
                    'success': False,
                    'message': data.get('message', 'Error sending SMS')
                }
        except requests.exceptions.RequestException as e:
            current_app.logger.error(f"Error communicating with Chinguisoft API: {e}")
            return {
                'success': False,
                'message': 'Failed to send SMS due to network error.'
            }
