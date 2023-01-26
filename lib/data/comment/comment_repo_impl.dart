import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/comment/comment_repo.dart';

class CommentRepoImpl implements CommentRepo {
  @override
  Future<String> createComment({
    required String token,
    required String restaurantId,
    required String review,
    required int rating,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Comment>> getAllComments() {
    throw UnimplementedError();
  }

  @override
  Future<Comment> getCommentById({required String id}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Comment>> getCommentsByRestaurant({
    required String restaurantId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Comment>> getCommentsByUser({required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<Comment> updateComment({
    required String token,
    required String commentId,
    String? review,
    int? rating,
  }) {
    throw UnimplementedError();
  }
}
