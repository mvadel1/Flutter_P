import os

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 't9P8HRBNJVv61mcv5zabtjcSDbl_FRibOOQ5eDbHtqk')
    SQLALCHEMY_DATABASE_URI = f"postgresql://{os.getenv('DB_USER')}:" \
                              f"{os.getenv('DB_PASSWORD')}@" \
                              f"{os.getenv('DB_HOST')}:" \
                              f"{os.getenv('DB_PORT')}/" \
                              f"{os.getenv('DB_NAME')}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 't9P8HRBNJVv61mcv5zabtjcSDbl_FRibOOQ5eDbHtqk')
    JWT_VERIFY_SUB = False  
    SMSMIC_URL = os.getenv('SMSMIC_URL')