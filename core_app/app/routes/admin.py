from flask import Blueprint, request, jsonify
from .. import db
from ..models import User, Book, Order, InventoryLog
from ..schemas.user_schema import UserSchema
from ..schemas.book_schema import BookSchema
from ..schemas.order_schema import OrderSchema
from flask_jwt_extended import jwt_required, get_jwt_identity

admin_bp = Blueprint('admin', __name__)

print("test!") 
print(admin_bp)  


user_schema = UserSchema()
users_schema = UserSchema(many=True)
book_schema = BookSchema()
books_schema = BookSchema(many=True)
order_schema = OrderSchema()
orders_schema = OrderSchema(many=True)

def is_admin(user_id):
    user = User.query.get(user_id)
    return user and user.role == 'admin'


@admin_bp.before_request
@jwt_required()
def before_request():
    print("]Executing...")

    try:
        
        current_user_id = get_jwt_identity()
        print(f" User ID from JWT: {current_user_id}") 

        user = User.query.get(current_user_id)
        print(f"Retrieved User: {user}") 

        if not user or not is_admin(current_user_id):
            print("Access Denied: Not an admin")
            return jsonify({'message': 'Admin access required.'}), 403
    except Exception as e:
        print(f"JWT Error BEFORE execution: {e}") 
        return jsonify({'message': f'JWT Authentication failed: {e}'}), 401




@admin_bp.route('/users', methods=['GET'])
def get_all_users():

    users = User.query.all()
    return jsonify(users_schema.dump(users)), 200

@admin_bp.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    data = request.get_json()

    user.role = data.get('role', user.role)
    db.session.commit()
    return jsonify(user_schema.dump(user)), 200



@admin_bp.route('/orders', methods=['GET'])
def get_all_orders():

    orders = Order.query.all()
    return jsonify(orders_schema.dump(orders)), 200

@admin_bp.route('/orders/<int:order_id>', methods=['PUT'])
def update_order_status(order_id):

    order = Order.query.get_or_404(order_id)
    data = request.get_json()
    order.status = data.get('status', order.status)
    db.session.commit()
    return jsonify(order_schema.dump(order)), 200

@admin_bp.route('/orders/<int:order_id>', methods=['DELETE'])
def admin_delete_order(order_id):

    order = Order.query.get_or_404(order_id)
    db.session.delete(order)
    db.session.commit()
    return jsonify({'message': 'Order deleted successfully.'}), 200



@admin_bp.route('/books', methods=['GET'])
def admin_get_all_books():

    books = Book.query.all()
    return jsonify(books_schema.dump(books)), 200



@admin_bp.route('/books', methods=['POST'])
def admin_create_book():
    print("hi____+++++++++++++++")
    data = request.get_json()
    try:
        book_data = book_schema.load(data)  
        book = Book(**book_data) 
    except Exception as e:
        return jsonify({'message': str(e)}), 400

    db.session.add(book)
    db.session.commit()
    return jsonify(book_schema.dump(book)), 201


@admin_bp.route('/books/<int:book_id>', methods=['PUT'])
def admin_update_book(book_id):
    book = Book.query.get_or_404(book_id)
    data = request.get_json()

    try:
        validated_data = book_schema.load(data, partial=True)
    except Exception as e:
        return jsonify({'message': str(e)}), 400

    for key, value in validated_data.items():
        setattr(book, key, value)

    db.session.commit()
    return jsonify(book_schema.dump(book)), 200


@admin_bp.route('/books/<int:book_id>', methods=['DELETE'])
def admin_delete_book(book_id):

    book = Book.query.get_or_404(book_id)
    db.session.delete(book)
    db.session.commit()
    return jsonify({'message': 'Book deleted successfully.'}), 200



@admin_bp.route('/books/<int:book_id>/restock', methods=['POST'])
def admin_restock_book(book_id):

    book = Book.query.get_or_404(book_id)
    data = request.get_json()
    amount = data.get('amount')
    reason = data.get('reason', 'restock')

    if not amount or not isinstance(amount, int) or amount <= 0:
        return jsonify({'message': 'Invalid restock amount.'}), 400

    book.stock_quantity += amount
    db.session.add(book)
    
    log = InventoryLog(book_id=book.id, change_amount=amount, reason=reason)
    db.session.add(log)
    db.session.commit()

    return jsonify({'message': 'Book restocked successfully.'}), 200



@admin_bp.route('/analytics', methods=['GET'])
def admin_analytics():

    total_users = User.query.count()
    total_books = Book.query.count()
    total_orders = Order.query.count()

    return jsonify({
        'total_users': total_users,
        'total_books': total_books,
        'total_orders': total_orders
    }), 200
