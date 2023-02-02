import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/profile/profile_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CltCommentCard extends StatelessWidget {
  final Comment comment;
  final double width;
  final void Function() editComment;
  final void Function() deleteComment;

  const CltCommentCard({
    Key? key,
    required this.comment,
    required this.width,
    required this.editComment,
    required this.deleteComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var currentUser = authProvider.user;
    var shouldShowEditBtn =
        currentUser != null && currentUser.id == comment.user.id;

    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 10,
        ),
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: shouldShowEditBtn ? 0 : 4,
                bottom: shouldShowEditBtn ? 0 : 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(userId: comment.user.id),
                      ),
                    ),
                    splashFactory: InkRipple.splashFactory,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: mediumOrange,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              comment.user.image!.url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        CltHeading(
                          text: comment.user.username,
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  if (shouldShowEditBtn)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "edit") {
                          return editComment();
                        }
                        deleteComment();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          child: Text("Edit Comment"),
                          value: "edit",
                        ),
                        const PopupMenuItem(
                          child: Text("Delete Comment"),
                          value: "delete",
                        ),
                      ],
                    )
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              comment.review,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: mediumOrange,
                ),
                const SizedBox(width: 5),
                Text(
                  comment.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Opacity(
                  opacity: 0.5,
                  child: Text(
                    "/5",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Opacity(
              opacity: 0.5,
              child: Row(
                children: [
                  Text(
                    DateFormat('dd MMM yyyy hh:mm:ss a')
                        .format(comment.updatedAt),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (comment.updatedAt != comment.createdAt)
                    const Text("(Edited)")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
