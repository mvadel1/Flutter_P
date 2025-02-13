# import bcrypt
# import jwt
# from flask import current_app
# from datetime import datetime, timedelta

# def hash_password(password):
#     return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

# def check_password(password, hashed):
#     return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

# def generate_jwt(user_id):
#     payload = {
#         'exp': datetime.utcnow() + timedelta(days=1),
#         'iat': datetime.utcnow(),
#         'sub': user_id
#     }
#     return jwt.encode(
#         payload,
#         current_app.config.get('JWT_SECRET_KEY'),
#         algorithm='HS256'
#     )

# change it to somthing better 

import bcrypt

def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def check_password(password, hashed):
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
