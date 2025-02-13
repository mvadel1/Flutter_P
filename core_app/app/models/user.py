from .. import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    phone_number = db.Column(db.String(15), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    role = db.Column(db.String(20), default='user')
    is_verified = db.Column(db.Boolean, default=False) 
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    reset_token_confirmed = db.Column(db.Boolean, default=False) 


 
    email = db.Column(db.String(120), unique=True, nullable=True)
    reset_token = db.Column(db.String(200), nullable=True)
    reset_token_expires = db.Column(db.DateTime, nullable=True)

    
    orders = db.relationship('Order', backref='user', lazy=True)
