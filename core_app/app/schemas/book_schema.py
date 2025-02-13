from marshmallow import Schema, fields

class BookSchema(Schema):
    id = fields.Int(dump_only=True)
    title = fields.Str(required=True)
    author = fields.Str(required=True)
    isbn = fields.Str(required=True)
    price = fields.Float(required=True)
    stock_quantity = fields.Int()
    description = fields.Str()
    category = fields.Str()
    cover_image = fields.Str()
    created_at = fields.DateTime(dump_only=True)
    