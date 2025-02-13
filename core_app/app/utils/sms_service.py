import requests
from flask import current_app

def send_verification_code(phone_number, lang):
    SMSMIC_URL = current_app.config.get('SMSMIC_URL', 'http://localhost:5001')
    url = f"{SMSMIC_URL}/api/sms/send_sms" 
    print('1________________________________',url)
    payload = {'phone': phone_number, 'lang': lang}
    try:
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            return {'success': True}
        else:
            data = response.json()
            return {'success': False, 'message': data.get('message', 'Error sending SMS')}
    except Exception as e:
        return {'success': False, 'message': str(e)}

def verify_code(phone_number, code):
    SMSMIC_URL = current_app.config.get('SMSMIC_URL', 'http://localhost:5001')
    url = f"{SMSMIC_URL}/api/sms/verify_sms" 
    payload = {'phone': phone_number, 'code': code}
    try:
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            data = response.json()
            return {'verified': data.get('verified', False)}
        else:
            data = response.json()
            return {'verified': False, 'message': data.get('message', 'Verification failed')}
    except Exception as e:
        return {'verified': False, 'message': str(e)}
