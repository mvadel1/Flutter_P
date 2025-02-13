from flask import Blueprint, request, jsonify
from ..services.chinguisoft_service import ChinguisoftService
from ..config import Config
from .. import db
from ..models.otp_code import OtpCode
from datetime import datetime

sms_bp = Blueprint('sms', __name__)
chinguisoft_service = ChinguisoftService(
    Config.VALIDATION_KEY,
    Config.VALIDATION_TOKEN,
    Config.APP_NAME
)

@sms_bp.route('/send_sms', methods=['POST'])
def send_sms():
    data = request.get_json()
    phone = data.get('phone')
    lang = data.get('lang', 'fr')

    if not phone:
        return jsonify({'message': 'Phone number is required.'}), 400

    result = chinguisoft_service.send_validation_sms(phone, lang)
    if result.get('success'):
        code = result['code']

        otp = OtpCode(phone=phone, code=code, ttl_minutes=10)
        db.session.add(otp)
        db.session.commit()

        return jsonify({'message': 'SMS sent successfully.'}), 200
    else:
        return jsonify({'message': 'SMS sending failed.', 'error': result.get('message')}), 400

@sms_bp.route('/verify_sms', methods=['POST'])
def verify_sms():
    data = request.get_json()
    phone = data.get('phone')
    code = data.get('code')

    if not phone or not code:
        return jsonify({'verified': False, 'message': 'Missing phone or code'}), 400


    otp = (OtpCode.query
           .filter_by(phone=phone, code=code)
           .order_by(OtpCode.id.desc())
           .first())

    if not otp:
        return jsonify({'verified': False, 'message': 'Code not found'}), 400

    if otp.is_expired():
        return jsonify({'verified': False, 'message': 'Code expired'}), 400

    db.session.delete(otp)
    db.session.commit()

    return jsonify({'verified': True}), 200
