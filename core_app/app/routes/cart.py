from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from .. import db
from ..models import Cart, Book
from ..schemas.cart_schema import CartSchema

cart_bp = Blueprint('cart', __name__)
cart_schema = CartSchema()
cart_items_schema = CartSchema(many=True)

@cart_bp.route('/', methods=['GET'])
@jwt_required()
def get_cart():
    current_user_id = int(get_jwt_identity())
    items = Cart.query.filter_by(user_id=current_user_id).all()
    return jsonify(cart_items_schema.dump(items)), 200

@cart_bp.route('/', methods=['POST'])
@jwt_required()
def add_to_cart():
    current_user_id = int(get_jwt_identity())
    data = request.get_json()
    book_id = data.get('book_id')
    quantity = data.get('quantity', 1)

    if not book_id:
        return jsonify({'message': 'book_id is required.'}), 400

    book = Book.query.get(book_id)
    if not book:
        return jsonify({'message': 'Book not found.'}), 404

    existing_item = Cart.query.filter_by(user_id=current_user_id, book_id=book_id).first()
    if existing_item:
        existing_item.quantity += quantity
        db.session.commit()
        return jsonify(cart_schema.dump(existing_item)), 200
    else:
        new_item = Cart(user_id=current_user_id, book_id=book_id, quantity=quantity)
        db.session.add(new_item)
        db.session.commit()
        return jsonify(cart_schema.dump(new_item)), 201

@cart_bp.route('/<int:cart_item_id>', methods=['PUT'])
@jwt_required()
def update_cart_item(cart_item_id):
    current_user_id = int(get_jwt_identity())
    data = request.get_json()
    quantity = data.get('quantity')

    if quantity is None or not isinstance(quantity, int) or quantity <= 0:
        return jsonify({'message': 'Invalid quantity'}), 400

    item = Cart.query.filter_by(id=cart_item_id, user_id=current_user_id).first_or_404()
    item.quantity = quantity
    db.session.commit()
    return jsonify(cart_schema.dump(item)), 200

@cart_bp.route('/<int:cart_item_id>', methods=['DELETE'])
@jwt_required()
def delete_cart_item(cart_item_id):
    current_user_id = int(get_jwt_identity())
    item = Cart.query.filter_by(id=cart_item_id, user_id=current_user_id).first_or_404()
    db.session.delete(item)
    db.session.commit()
    return jsonify({'message': 'Cart item deleted.'}), 200

@cart_bp.route('/clear', methods=['DELETE'])
@jwt_required()
def clear_cart():
    current_user_id = int(get_jwt_identity())
    Cart.query.filter_by(user_id=current_user_id).delete()
    db.session.commit()
    return jsonify({'message': 'Cart cleared.'}), 200
