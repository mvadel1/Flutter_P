import os

class Config:
    VALIDATION_KEY = os.getenv('VALIDATION_KEY', '3l3BXjPO2zEXOELE')
    VALIDATION_TOKEN = os.getenv('VALIDATION_TOKEN', 'YQOaZtW2AEMSozEuPylacSWPAprbrfv9')
    APP_NAME = os.getenv('APP_NAME', 'el_maktaba')

    
    SQLALCHEMY_DATABASE_URI = os.getenv('SMSMIC_DATABASE_URI', 'sqlite:///smsmic.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
