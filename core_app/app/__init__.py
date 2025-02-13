from flask import Flask, jsonify, request
import logging 
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from .config import Config
from dotenv import load_dotenv
from flask_cors import CORS

from flask_jwt_extended import exceptions as jwt_exceptions


db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

def create_app():
    load_dotenv()  

    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)

    CORS(app, resources={r"/api/*": {"origins": "*"}})

    from .routes.auth import auth_bp
    from .routes.books import books_bp
    from .routes.orders import orders_bp
    from .routes.admin import admin_bp
    from .routes.cart import cart_bp
    
    app.register_blueprint(cart_bp, url_prefix='/api/cart')
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(books_bp, url_prefix='/api/books')
    app.register_blueprint(orders_bp, url_prefix='/api/orders')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')


    logging.basicConfig(level=logging.DEBUG)
    handler = logging.StreamHandler()
    handler.setLevel(logging.DEBUG)
    app.logger.addHandler(handler)


    @app.errorhandler(jwt_exceptions.JWTDecodeError)
    def handle_jwt_decode_error(e):
        app.logger.error(f"JWT Decode Error: {e}")
        return jsonify({'message': 'Invalid JWT token.'}), 422

    @app.errorhandler(jwt_exceptions.NoAuthorizationError)
    def handle_no_auth_error(e):
        app.logger.error(f"No Authorization Error: {e}")
        return jsonify({'message': 'Authorization token required.'}), 422

    @app.errorhandler(jwt_exceptions.WrongTokenError)
    def handle_wrong_token_error(e):
        app.logger.error(f"Wrong Token Error: {e}")
        return jsonify({'message': 'Incorrect JWT token.'}), 422

    @app.errorhandler(jwt_exceptions.RevokedTokenError)
    def handle_revoked_token_error(e):
        app.logger.error(f"Revoked Token Error: {e}")
        return jsonify({'message': 'JWT token has been revoked.'}), 422



    @app.before_request
    def log_request_info():
        app.logger.debug(f"Request Method: {request.method}")
        app.logger.debug(f"Request URL: {request.url}")
        app.logger.debug(f"Request Headers: {request.headers}")
        app.logger.debug(f"Request Body: {request.get_data()}")

    
    return app
