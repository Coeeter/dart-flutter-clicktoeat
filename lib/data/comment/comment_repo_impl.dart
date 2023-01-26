import 'package:clicktoeat/data/comment/remote/remote_comment_dao.dart';
import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/comment/comment_repo.dart';

class CommentRepoImpl implements CommentRepo {
  final RemoteCommentDao _dao;

  CommentRepoImpl({required RemoteCommentDao remoteCommentDao})
      : _dao = remoteCommentDao;

  @override
  Future<String> createComment({
    required String token,
    required String restaurantId,
    required String review,
    required int rating,
  }) {
    return _dao.createComment(
      token: token,
      restaurantId: restaurantId,
      review: review,
      rating: rating,
    );
  }

  @override
  Future<void> deleteComment({
    required String token,
    required String commentId,
  }) {
    return _dao.deleteComment(
      token: token,
      commentId: commentId,
    );
  }

  @override
  Future<List<Comment>> getAllComments() {
    return _dao.getAllComments();
  }

  @override
  Future<Comment> getCommentById({required String id}) {
    return _dao.getCommentById(id: id);
  }

  @override
  Future<List<Comment>> getCommentsByRestaurant({
    required String restaurantId,
  }) {
    return _dao.getCommentsByRestaurant(restaurantId: restaurantId);
  }

  @override
  Future<List<Comment>> getCommentsByUser({required String userId}) {
    return _dao.getCommentsByUser(userId: userId);
  }

  @override
  Future<Comment> updateComment({
    required String token,
    required String commentId,
    String? review,
    int? rating,
  }) {
    return _dao.updateComment(
      token: token,
      commentId: commentId,
      review: review,
      rating: rating
    );
  }
}
