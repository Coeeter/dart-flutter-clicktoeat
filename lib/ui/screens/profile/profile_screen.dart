import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/clt_restaurant_card.dart';
import 'package:clicktoeat/ui/components/comments/clt_comment_card.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var restaurantsProvider = Provider.of<RestaurantProvider>(context);
    var commentsProvider = Provider.of<CommentProvider>(context);
    var currentUser = authProvider.user;
    var commentsOfUser = commentsProvider.commentList
        .where((comment) => comment.user.id == user.id)
        .toList();
    var favoriteRestaurantsOfUser = restaurantsProvider.restaurantList
        .where(
          (restaurant) => restaurant.usersWhoFavRestaurant
              .map((e) => e.id)
              .contains(user.id),
        )
        .toList();
    var chunkedFavoriteRestaurants = <List<TransformedRestaurant>>[];
    for (var i = 0; i < favoriteRestaurantsOfUser.length; i += 2) {
      chunkedFavoriteRestaurants.add(
        favoriteRestaurantsOfUser.skip(i).take(2).toList(),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            _buildAppBar(context, currentUser),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserStats(
                commentsOfUser,
                favoriteRestaurantsOfUser,
              ),
              const SizedBox(height: 10),
              _buildFavRestaurantSection(
                commentsProvider,
                restaurantsProvider,
                authProvider,
                chunkedFavoriteRestaurants,
                currentUser,
              ),
              const SizedBox(height: 10),
              _buildReviewsSection(commentsOfUser),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavRestaurantSection(
    CommentProvider commentsProvider,
    RestaurantProvider restaurantsProvider,
    AuthProvider authProvider,
    List<List<TransformedRestaurant>> chunkedFavoriteRestaurants,
    User? currentUser,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CltHeading(text: "Favorite Restaurants"),
        const SizedBox(height: 5),
        ...chunkedFavoriteRestaurants.map(
          (restaurantRow) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CltRestaurantCard(
                      transformedRestaurant: restaurantRow[0],
                      commentsOfRestaurant: commentsProvider.commentList
                          .where(
                            (element) =>
                                element.restaurant.id ==
                                restaurantRow[0].restaurant.id,
                          )
                          .toList(),
                      currentUser: currentUser,
                      toggleFavorite: (shouldFavorite, restaurantId) {
                        restaurantsProvider.toggleRestaurantFavorite(
                          authProvider.token!,
                          restaurantId,
                          currentUser!,
                          shouldFavorite,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: restaurantRow.length == 1
                        ? Container()
                        : CltRestaurantCard(
                            transformedRestaurant: restaurantRow[1],
                            commentsOfRestaurant: commentsProvider.commentList
                                .where(
                                  (element) =>
                                      element.restaurant.id ==
                                      restaurantRow[1].restaurant.id,
                                )
                                .toList(),
                            currentUser: currentUser,
                            toggleFavorite: (shouldFavorite, restaurantId) {
                              restaurantsProvider.toggleRestaurantFavorite(
                                authProvider.token!,
                                restaurantId,
                                currentUser!,
                                shouldFavorite,
                              );
                            },
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        if (chunkedFavoriteRestaurants.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [lightOrange, mediumOrange],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.heart_broken,
                    size: 150,
                  ),
                ),
                const Text(
                  "No favorites yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildReviewsSection(List<Comment> commentsOfUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CltHeading(text: "Reviews"),
        const SizedBox(height: 5),
        ...commentsOfUser.map(
          (comment) => Column(
            children: [
              CltCommentCard(
                comment: comment,
                width: double.infinity,
                editComment: () {},
                deleteComment: () {},
                commentMode: CommentMode.restaurant,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        if (commentsOfUser.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [lightOrange, mediumOrange],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.message,
                    size: 150,
                  ),
                ),
                const Text(
                  "No reviews yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Material _buildUserStats(
    List<Comment> commentsOfUser,
    List<TransformedRestaurant> favoriteRestaurantsOfUser,
  ) {
    return Material(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                CltHeading(
                  text: _getAvgRating(commentsOfUser).toStringAsFixed(1),
                ),
                const Text("AVG Rating"),
              ],
            ),
            Column(
              children: [
                CltHeading(
                  text: commentsOfUser.length.toString(),
                ),
                const Text("Reviews"),
              ],
            ),
            Column(
              children: [
                CltHeading(
                  text: favoriteRestaurantsOfUser.length.toString(),
                ),
                const Text("Favorites"),
              ],
            )
          ],
        ),
      ),
    );
  }

  double _getAvgRating(List<Comment> commentList) {
    if (commentList.isEmpty) return 0;
    var totalRating = commentList.fold<double>(
      0,
      (previousValue, element) => previousValue + element.rating,
    );
    return totalRating / commentList.length.toDouble();
  }

  Widget _buildAppBar(BuildContext context, User? currentUser) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      actions: [
        if (currentUser != null && currentUser.id == user.id)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {}, // TODO: Navigate to edit profile screen
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          user.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
        background: Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? mediumOrange
                        : Colors.white,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: user.image == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 100,
                      )
                    : ClipOval(
                        child: Image.network(
                          user.image!.url,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              if (currentUser != null && currentUser.id == user.id)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Material(
                    elevation: 4,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? ElevationOverlay.colorWithOverlay(
                            Theme.of(context).colorScheme.surface,
                            Colors.white,
                            50,
                          )
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () {}, // TODO: Update profile picture
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              colors: [lightOrange, mediumOrange],
                            ).createShader(
                              Rect.fromLTWH(0, 0, rect.width, rect.height),
                            );
                          },
                          child: const Icon(
                            Icons.camera_alt,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
