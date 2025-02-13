from marshmallow import Schema, fields

class OrderSchema(Schema):
    id = fields.Int(dump_only=True)
    user_id = fields.Int(required=True)
    book_id = fields.Int(required=True)
    quantity = fields.Int()
    status = fields.Str()
    created_at = fields.DateTime()
