import 'dart:io';

import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/clt_restaurant_card.dart';
import 'package:clicktoeat/ui/components/comments/clt_comment_card.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/profile/profile_picture_picker.dart';
import 'package:clicktoeat/ui/screens/profile/update_profile_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isUpdatingImage = false;

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var restaurantsProvider = Provider.of<RestaurantProvider>(context);
    var commentsProvider = Provider.of<CommentProvider>(context);
    var currentUser = authProvider.user;
    var commentsOfUser = commentsProvider.commentList
        .where((comment) => comment.user.id == widget.user.id)
        .toList();
    var favoriteRestaurantsOfUser = restaurantsProvider.restaurantList
        .where(
          (restaurant) => restaurant.usersWhoFavRestaurant
              .map((e) => e.id)
              .contains(widget.user.id),
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
                  ...restaurantRow.map(
                    (r) => Expanded(
                      child: CltRestaurantCard(
                        transformedRestaurant: r,
                        commentsOfRestaurant: commentsProvider.commentList
                            .where(
                              (element) =>
                                  element.restaurant.id == r.restaurant.id,
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
                  ),
                  if (restaurantRow.length == 1) Expanded(child: Container())
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
        if (currentUser != null && currentUser.id == widget.user.id)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UpdateProfileScreen(),
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.user.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
        background: Center(
          child: ProfilePicturePicker(user: widget.user),
        ),
      ),
    );
  }
}
