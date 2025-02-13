from datetime import datetime
from app import db

class InventoryLog(db.Model):
    __tablename__ = 'inventory_logs'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)  
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'), nullable=False)
    change_amount = db.Column(db.Integer, nullable=False)
    reason = db.Column(db.String(50), nullable=False, default='restock')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
