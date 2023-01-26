import 'package:clicktoeat/domain/comment/comment.dart';

abstract class CommentRepo {
  Future<List<Comment>> getAllComments();
  Future<Comment> getCommentId({required String id});
  Future<List<Comment>> getCommentsByUser({required String userId});
  Future<List<Comment>> getCommentsByRestaurant({required String restaurantId});
  Future<String> createComment({
    required String token,
    required String restaurantId,
    required String review,
    required int rating,
  });
  Future<String> updateComment({
    required String token,
    required String commentId,
    String? review,
    int? rating,
  });
  Future<void> deleteComment({
    required String token,
    required String commentId,
  });
}
