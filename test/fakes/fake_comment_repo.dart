import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/comment/comment_repo.dart';
import 'package:clicktoeat/domain/common/image.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';
import 'package:clicktoeat/domain/user/user.dart';

class FakeCommentRepo implements CommentRepo {
  List<Comment> _comments = [];

  FakeCommentRepo() {
    _comments = List.generate(
      10,
      (index) => Comment(
        id: index.toString(),
        review: 'review $index',
        rating: index,
        restaurant: _createRestaurant(index.toString()),
        user: _createUser(index.toString()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  User _createUser(String id) {
    return User(
      id: id,
      username: "username $id",
      email: "email $id",
      image: Image(
        id: id.hashCode,
        key: "key",
        url: 'https://picsum.photos/200/200',
      ),
    );
  }

  Restaurant _createRestaurant(String id) {
    return Restaurant(
      id: id,
      name: "name $id",
      description: "description $id",
      branches: [],
      image: Image(
        id: int.parse(id),
        key: "key",
        url: 'https://picsum.photos/200/200',
      ),
    );
  }

  @override
  Future<String> createComment({
    required String token,
    required String restaurantId,
    required String review,
    required int rating,
  }) async {
    var comment = Comment(
      id: _comments.length.toString(),
      review: review,
      rating: rating,
      restaurant: _createRestaurant(restaurantId),
      user: _createUser('9'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _comments.add(comment);
    return comment.id;
  }

  @override
  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) async {
    _comments.removeWhere((element) => element.id == commentId);
  }

  @override
  Future<List<Comment>> getAllComments() async {
    return _comments;
  }

  @override
  Future<Comment> getCommentById({required String id}) async {
    return _comments.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<Comment>> getCommentsByRestaurant({
    required String restaurantId,
  }) async {
    return _comments
        .where((element) => element.restaurant.id == restaurantId)
        .toList();
  }

  @override
  Future<List<Comment>> getCommentsByUser({required String userId}) async {
    return _comments.where((element) => element.user.id == userId).toList();
  }

  @override
  Future<Comment> updateComment({
    required String token,
    required String commentId,
    String? review,
    int? rating,
  }) async {
    var comment = _comments.firstWhere((element) => element.id == commentId);
    var updatedComment = Comment(
      id: comment.id,
      review: review ?? comment.review,
      rating: rating ?? comment.rating,
      restaurant: comment.restaurant,
      user: comment.user,
      createdAt: comment.createdAt,
      updatedAt: DateTime.now(),
    );
    _comments = _comments.map((e) {
      if (e.id == commentId) {
        return updatedComment;
      }
      return e;
    }).toList();
    return comment;
  }
}
