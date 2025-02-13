from marshmallow import Schema, fields

class UserSchema(Schema):
    id = fields.Int(dump_only=True)
    name = fields.Str(required=True)
    email = fields.Str(required=True)
    phone_number = fields.Str(required=True)
    role = fields.Str()
    created_at = fields.DateTime()
