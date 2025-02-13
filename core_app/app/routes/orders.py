from flask import Blueprint, request, jsonify
from .. import db
from ..models import Order, Book
from ..schemas.order_schema import OrderSchema
from flask_jwt_extended import jwt_required, get_jwt_identity

orders_bp = Blueprint('orders', __name__)
order_schema = OrderSchema()
orders_schema = OrderSchema(many=True)

@orders_bp.route('/', methods=['POST'])
@jwt_required()
def place_order():
    current_user_id = int(get_jwt_identity())  
    data = request.get_json()

    book_id = data.get('book_id')
    quantity = data.get('quantity', 1)

    if not book_id:
        return jsonify({'message': 'Book ID is required.'}), 400

    book = Book.query.get_or_404(book_id)
    if book.stock_quantity < quantity:
        return jsonify({'message': 'Not enough stock available.'}), 400

    order = Order(
        user_id=current_user_id,
        book_id=book_id,
        quantity=quantity,
        status='processing'
    )
    book.stock_quantity -= quantity
    db.session.add(order)
    db.session.commit()

    return jsonify(order_schema.dump(order)), 201


@orders_bp.route('/', methods=['GET'])
@jwt_required()
def get_orders():

    current_user_id = get_jwt_identity()
    orders = Order.query.filter_by(user_id=current_user_id).all()
    return jsonify(orders_schema.dump(orders)), 200

@orders_bp.route('/<int:order_id>', methods=['GET'])
@jwt_required()
def get_order(order_id):

    current_user_id = get_jwt_identity()
    order = Order.query.filter_by(id=order_id, user_id=current_user_id).first_or_404()
    return jsonify(order_schema.dump(order)), 200

@orders_bp.route('/<int:order_id>', methods=['DELETE'])
@jwt_required()
def delete_order(order_id):
    current_user_id = get_jwt_identity()
    order = Order.query.filter_by(id=order_id, user_id=current_user_id).first_or_404()

    if order.status != 'processing':
        return jsonify({'message': 'Cannot delete an order that is not in processing status.'}), 400

    book = Book.query.get(order.book_id)
    if book:
        book.stock_quantity += order.quantity
        db.session.add(book)

    db.session.delete(order)
    db.session.commit()
    return jsonify({'message': 'Order deleted successfully.'}), 200