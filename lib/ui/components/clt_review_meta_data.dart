import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class CltReviewMetaData extends StatelessWidget {
  final List<Comment> commentsOfRestaurant;

  const CltReviewMetaData({
    Key? key,
    required this.commentsOfRestaurant,
  }) : super(key: key);

  double _getAvgRating(List<Comment> commentList) {
    if (commentList.isEmpty) return 0;
    var totalRating = commentList.fold<double>(
      0,
      (previousValue, element) => previousValue + element.rating,
    );
    return totalRating / commentList.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  _getAvgRating(commentsOfRestaurant).toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Opacity(
                  opacity: 0.5,
                  child: Text(
                    "out of 5",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ...List.generate(
                            5 - index,
                            (_) => const Icon(
                              Icons.star,
                              size: 10,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn,
                              tween: Tween(
                                begin: 0,
                                end: commentsOfRestaurant.where((element) {
                                      return element.rating == 5 - index;
                                    }).length /
                                    commentsOfRestaurant.length,
                              ),
                              builder: (context, value, _) {
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: lightOrange.withAlpha(100),
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: Text(
                        commentsOfRestaurant.length.toString() + " reviews"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
