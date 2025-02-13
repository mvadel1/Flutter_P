from marshmallow import Schema, fields

class CartSchema(Schema):
    id = fields.Int(dump_only=True)
    user_id = fields.Int(required=True)
    book_id = fields.Int(required=True)
    quantity = fields.Int()
    created_at = fields.DateTime()
