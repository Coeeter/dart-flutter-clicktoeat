import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/ui/components/comments/clt_comment_card.dart';
import 'package:clicktoeat/ui/components/comments/clt_create_comment.dart';
import 'package:clicktoeat/ui/components/comments/clt_edit_comment_dialog.dart';
import 'package:clicktoeat/ui/components/comments/clt_review_meta_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatelessWidget {
  final String restaurantId;

  const CommentsScreen({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var commentProvider = Provider.of<CommentProvider>(context);
    var comments = commentProvider.commentList
        .where((element) => element.restaurant.id == restaurantId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            children: [
              CltCreateCommentForm(restaurantId: restaurantId),
              const SizedBox(height: 10),
              CltReviewMetaData(commentsOfRestaurant: comments),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return CltCommentCard(
                    comment: comment,
                    width: double.infinity,
                    editComment: () {
                      showDialog(
                        context: context,
                        builder: (_) => CltEditCommentDialog(comment: comment),
                      );
                    },
                    deleteComment: () async {
                      try {
                        await commentProvider.deleteComment(
                          Provider.of<AuthProvider>(context, listen: false)
                              .token!,
                          comment.id,
                        );
                      } on DefaultException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.error),
                          ),
                        );
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
              ),
            ],
          )),
    );
  }
}
