import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final TransformedRestaurant transformedRestaurant;
  final List<Comment> commentsOfRestaurant;
  final User? currentUser;
  final void Function() toggleFavorite;

  const RestaurantCard({
    Key? key,
    required this.transformedRestaurant,
    required this.commentsOfRestaurant,
    required this.currentUser,
    required this.toggleFavorite,
  }) : super(key: key);

  double get averageRating {
    if (commentsOfRestaurant.isEmpty) return 0;
    var totalRating = commentsOfRestaurant.fold<double>(
        0, (previousValue, element) => previousValue + element.rating);
    return totalRating / commentsOfRestaurant.length;
  }

  bool get isFavoritedByCurrentUser {
    return commentsOfRestaurant.map((e) => e.user.id).contains(currentUser?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: mediumOrange,
                  width: 2,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  transformedRestaurant.restaurant.image!.url,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          transformedRestaurant.restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [lightOrange, mediumOrange],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            );
                          },
                          child: Icon(
                            isFavoritedByCurrentUser
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                        ),
                        splashRadius: 20,
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: mediumOrange),
                      const SizedBox(width: 2),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "/5 (${commentsOfRestaurant.length})",
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
