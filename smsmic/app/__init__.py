from flask import Flask
from .config import Config
from flask_cors import CORS
from dotenv import load_dotenv
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from .models.otp_code import OtpCode 

db = SQLAlchemy()
migrate = Migrate()

def create_app():
    load_dotenv()

    app = Flask(__name__)
    app.config.from_object(Config)

    # Enable CORS
    CORS(app)


    db.init_app(app)
    migrate.init_app(app, db)

    

    from .routes import sms_bp
    app.register_blueprint(sms_bp, url_prefix='/api/sms')

    return app
