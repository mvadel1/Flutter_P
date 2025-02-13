from flask import Blueprint, request, jsonify, Response
from .. import db
from ..models import User
from ..schemas.user_schema import UserSchema
from ..utils.helpers import hash_password, check_password
from ..utils.sms_service import send_verification_code, verify_code
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from ..utils.email_service import send_reset_email
import secrets
from datetime import timedelta, datetime

auth_bp = Blueprint('auth', __name__)
user_schema = UserSchema()

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    name = data.get('name')
    phone_number = data.get('phone_number')
    email = data.get('email')  
    password = data.get('password')
    lang = data.get('lang', 'fr')

    if not all([name, phone_number, password]):
        return jsonify({'message': 'Name, phone number and password required.'}), 400

    if email and User.query.filter_by(email=email).first():
        return jsonify({'message': 'User with this email already exists.'}), 409

    if User.query.filter_by(phone_number=phone_number).first():
        return jsonify({'message': 'User with this phone number already exists.'}), 409

    password_hash = hash_password(password)
    new_user = User(
        name=name,
        phone_number=phone_number,
        email=email,
        password_hash=password_hash,
        role='user',
        is_verified=False
    )
    db.session.add(new_user)
    db.session.commit()

    # Send phone verification OTP
    sms_result = send_verification_code(phone_number, lang)
    if not sms_result.get('success'):
        return jsonify({
            'message': 'User registered but SMS sending failed.',
            'error': sms_result.get('message')
        }), 201

    return jsonify({
        'message': 'User registered successfully. Please verify your phone number.'
    }), 201


@auth_bp.route('/verify', methods=['POST'])
def verify():
    data = request.get_json()
    phone_number = data.get('phone_number')
    code = data.get('code')

    if not all([phone_number, code]):
        return jsonify({'message': 'Phone number and code are required.'}), 400

    user = User.query.filter_by(phone_number=phone_number).first()
    if not user:
        return jsonify({'message': 'User not found.'}), 404

    if user.is_verified:
        return jsonify({'message': 'User already verified.'}), 200

    verification_result = verify_code(phone_number, code)
    if verification_result.get('verified'):
        user.is_verified = True
        db.session.commit()
        return jsonify({'message': 'Phone number verified successfully.'}), 200
    else:
        return jsonify({'message': 'Invalid or expired verification code.'}), 400


@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    phone_number = data.get('phone_number')
    password = data.get('password')

    if not all([phone_number, password]):
        return jsonify({'message': 'Phone number and password are required.'}), 400

    user = User.query.filter_by(phone_number=phone_number).first()
    if not user or not check_password(password, user.password_hash):
        return jsonify({'message': 'Invalid phone number or password.'}), 401

    if user.reset_token and user.reset_token_expires and user.reset_token_expires > datetime.utcnow():
        return jsonify({
            'message': 'A password reset is in progress. Please complete or cancel the reset process before logging in.'
        }), 403

    access_token = create_access_token(identity=str(user.id))
    return jsonify({'access_token': access_token, 'role': user.role}), 200


@auth_bp.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    return jsonify({'message': f'Hello, {user.name}!'}), 200


@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def profile():
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    if not user:
        return jsonify({'message': 'User not found.'}), 404

    return jsonify({
        'id': user.id,
        'name': user.name,
        'phone_number': user.phone_number,
        'role': user.role,
        'is_verified': user.is_verified
    }), 200



@auth_bp.route('/forgot_password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    phone_number = data.get('phone_number')
    lang = data.get('lang', 'fr')

    if not phone_number:
        return jsonify({'message': 'Phone number is required.'}), 400

    user = User.query.filter_by(phone_number=phone_number).first()
    if not user:
        return jsonify({'message': 'No account found with this phone number.'}), 404

    sms_result = send_verification_code(phone_number, lang)
    if not sms_result.get('success'):
        return jsonify({
            'message': 'Failed to send SMS for password reset.',
            'error': sms_result.get('message')
        }), 400

    return jsonify({'message': 'SMS code sent. Please verify via /reset_password.'}), 200


@auth_bp.route('/reset_password', methods=['POST'])
def reset_password():
    data = request.get_json()
    phone_number = data.get('phone_number')
    code = data.get('code')
    new_password = data.get('new_password')

    if not all([phone_number, code, new_password]):
        return jsonify({'message': 'Phone number, code, and new password are required.'}), 400

    user = User.query.filter_by(phone_number=phone_number).first()
    if not user:
        return jsonify({'message': 'User not found.'}), 404

    verification_result = verify_code(phone_number, code)
    if not verification_result.get('verified'):
        return jsonify({'message': 'Invalid or expired code.'}), 400

    user.password_hash = hash_password(new_password)
    db.session.commit()
    return jsonify({'message': 'Password updated successfully.'}), 200


@auth_bp.route('/forgot_password_email', methods=['POST'])
def forgot_password_email():
    data = request.get_json()
    email = data.get('email')
    if not email:
        return jsonify({'message': 'Email is required.'}), 400

    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({'message': 'No account found with this email.'}), 404

    token = secrets.token_urlsafe(32)
    user.reset_token = token
    user.reset_token_expires = datetime.utcnow() + timedelta(hours=1)
    user.reset_token_confirmed = False 
    db.session.commit()

    reset_link = f"http://127.0.0.1:5000/api/auth/validate_reset_token/{token}"
    email_sent = send_reset_email(email, reset_link)
    if not email_sent:
        return jsonify({'message': 'Could not send email. Please try again later.'}), 500

    return jsonify({
        'message': 'Reset link sent to your email.',
        'token': token
    }), 200



@auth_bp.route('/validate_reset_token/<token>', methods=['GET'])
def validate_reset_token(token):
    user = User.query.filter_by(reset_token=token).first()
    if not user:
        return jsonify({'message': 'Invalid token'}), 400

    if not user.reset_token_expires or user.reset_token_expires < datetime.utcnow():
        return jsonify({'message': 'Token expired'}), 400

    user.reset_token_confirmed = True
    db.session.commit()
    return jsonify({'message': 'Token is valid. You can now reset your password on the app.'}), 200

@auth_bp.route('/check_reset_token/<token>', methods=['GET'])
def check_reset_token(token):
    user = User.query.filter_by(reset_token=token).first()
    if not user:
        return jsonify({'message': 'Invalid token'}), 400

    if not user.reset_token_expires or user.reset_token_expires < datetime.utcnow():
        return jsonify({'message': 'Token expired'}), 400

    if not user.reset_token_confirmed:
        return jsonify({'message': 'Token not confirmed'}), 400

    return jsonify({'message': 'Token confirmed'}), 200



@auth_bp.route('/confirm_reset_email', methods=['POST'])
def confirm_reset_email():

    data = request.get_json()
    token = data.get('token')
    new_password = data.get('new_password')

    if not token or not new_password:
        return jsonify({'message': 'Token and new_password are required'}), 400

    user = User.query.filter_by(reset_token=token).first()
    if not user:
        return jsonify({'message': 'Invalid token'}), 400

    if not user.reset_token_expires or user.reset_token_expires < datetime.utcnow():
        return jsonify({'message': 'Token expired'}), 400

    user.password_hash = hash_password(new_password)
    user.reset_token = None
    user.reset_token_expires = None
    db.session.commit()

    return jsonify({'message': 'Password updated successfully'}), 200
