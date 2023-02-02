import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/comment/comment_repo.dart';
import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepo _commentRepo;
  final BuildContext _context;
  List<Comment> commentList = [];

  CommentProvider(this._context, this._commentRepo) {
    getComments();
  }

  Future<void> getComments() async {
    try {
      commentList = await _commentRepo.getAllComments();
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<Comment> getCommentById(String id) async {
    var comment = await _commentRepo.getCommentById(id: id);
    return comment;
  }

  Future<void> createComment(
    String token,
    String restaurantId,
    String review,
    int rating,
  ) async {
    var insertId = await _commentRepo.createComment(
      token: token,
      restaurantId: restaurantId,
      review: review,
      rating: rating,
    );
    var comment = await _commentRepo.getCommentById(id: insertId);
    commentList = commentList
      ..add(comment)
      ..sort((a, b) {
        return b.updatedAt.compareTo(a.updatedAt);
      });
    notifyListeners();
  }

  Future<void> updateComment(
    String token,
    String commentId,
    String review,
    int rating,
  ) async {
    var comment = await _commentRepo.updateComment(
      token: token,
      commentId: commentId,
      review: review,
      rating: rating,
    );
    commentList = commentList.map((e) {
      if (e.id != commentId) return e;
      return comment;
    }).toList()
      ..sort((a, b) {
        return b.updatedAt.compareTo(a.updatedAt);
      });
    notifyListeners();
  }

  Future<void> deleteComment(String token, String commentId) async {
    var oldCommentList = commentList;
    commentList = commentList.where((element) {
      return element.id != commentId;
    }).toList();
    notifyListeners();
    try {
      await _commentRepo.deleteComment(
        token: token,
        commentId: commentId,
      );
    } catch (e) {
      commentList = oldCommentList;
      notifyListeners();
      rethrow;
    }
  }
}
