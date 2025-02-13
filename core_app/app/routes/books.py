from flask import Blueprint, request, jsonify
from .. import db
from ..models import Book
from ..schemas.book_schema import BookSchema
from flask_jwt_extended import jwt_required

books_bp = Blueprint('books', __name__)
book_schema = BookSchema()
books_schema = BookSchema(many=True)

@books_bp.route('/', methods=['GET'])
def get_books():

    query = Book.query

    title = request.args.get('title')
    author = request.args.get('author')
    category = request.args.get('category')
    price_min = request.args.get('price_min')
    price_max = request.args.get('price_max')

    if title:
        query = query.filter(Book.title.ilike(f'%{title}%'))
    if author:
        query = query.filter(Book.author.ilike(f'%{author}%'))
    if category:
        query = query.filter(Book.category.ilike(f'%{category}%'))
    if price_min:
        query = query.filter(Book.price >= float(price_min))
    if price_max:
        query = query.filter(Book.price <= float(price_max))

    books = query.all()
    return jsonify(books_schema.dump(books)), 200

@books_bp.route('/<int:book_id>', methods=['GET'])
def get_book(book_id):

    book = Book.query.get_or_404(book_id)
    return jsonify(book_schema.dump(book)), 200
