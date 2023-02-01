import 'package:animations/animations.dart';
import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/screens/restaurant/restaurant_details_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final TransformedRestaurant transformedRestaurant;
  final List<Comment> commentsOfRestaurant;
  final User? currentUser;
  final void Function(
    bool toAddToFav,
    String restaurantId,
  ) toggleFavorite;

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
    return transformedRestaurant.usersWhoFavRestaurant
        .map((e) => e.id)
        .contains(currentUser?.id);
  }

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: OpenContainer(
        closedBuilder: (context, openContainer) => _buildClosedContent(
          context,
          openContainer,
        ),
        openBuilder: (context, closeContainer) => RestaurantDetailsScreen(
          restaurantId: transformedRestaurant.restaurant.id,
        ),
        closedElevation: 4,
        closedColor: isDarkMode
            ? ElevationOverlay.colorWithOverlay(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.onSurface,
                4,
              )
            : Colors.white,
        closedShape: const BeveledRectangleBorder(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fadeThrough,
        openColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _buildClosedContent(
    BuildContext context,
    void Function() openContainer,
  ) {
    return InkWell(
      onTap: openContainer,
      splashFactory: InkRipple.splashFactory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: mediumOrange,
                width: 2,
              ),
              color: Colors.white,
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
                      onPressed: () {
                        toggleFavorite(
                          !isFavoritedByCurrentUser,
                          transformedRestaurant.restaurant.id,
                        );
                      },
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
    );
  }
}
