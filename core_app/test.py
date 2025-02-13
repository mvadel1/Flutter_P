import os
from dotenv import load_dotenv


load_dotenv()


smsmic_url = os.getenv('SMSMIC_URL')
print(f"SMSMIC_URL: {smsmic_url}")
