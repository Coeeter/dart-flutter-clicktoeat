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

  Future<void> createComment(
    String token,
    String restaurantId,
    String review,
    int rating,
  ) async {
    try {
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
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> updateComment(
    String token,
    String commentId,
    String review,
    int rating,
  ) async {
    try {
      var comment = await _commentRepo.updateComment(
        token: token,
        commentId: commentId,
        review: review,
        rating: rating,
      );
      commentList = commentList
        ..add(comment)
        ..sort((a, b) {
          return b.updatedAt.compareTo(a.updatedAt);
        });
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }

  Future<void> deleteComment(String token, String commentId) async {
    try {
      await _commentRepo.deleteComment(
        token: token,
        commentId: commentId,
      );
      commentList = commentList.where((element) {
        return element.id != commentId;
      }).toList();
      notifyListeners();
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
    }
  }
}