from .. import db
from datetime import datetime, timedelta

class OtpCode(db.Model):
    __tablename__ = 'otp_codes'

    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(20), nullable=False)
    code = db.Column(db.String(6), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime)

    def __init__(self, phone, code, ttl_minutes=10):
        self.phone = phone
        self.code = code
        # expiry 10 minutes from creation
        self.expires_at = datetime.utcnow() + timedelta(minutes=ttl_minutes)

    def is_expired(self):
        return datetime.utcnow() > self.expires_at
