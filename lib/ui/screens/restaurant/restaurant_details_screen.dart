import 'dart:math';

import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/comments/clt_comment_card.dart';
import 'package:clicktoeat/ui/components/comments/clt_create_comment.dart';
import 'package:clicktoeat/ui/components/comments/clt_edit_comment_dialog.dart';
import 'package:clicktoeat/ui/components/comments/clt_review_meta_data.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/restaurant/comments_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailsScreen({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    var restaurantProvider = Provider.of<RestaurantProvider>(context);
    var commentProvider = Provider.of<CommentProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);
    var transformedRestaurant = restaurantProvider.restaurantList.firstWhere(
      (element) => element.restaurant.id == widget.restaurantId,
    );
    var commentsOfRestaurant = commentProvider.commentList
        .where((e) => e.restaurant.id == widget.restaurantId)
        .toList();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSilverHeader(
              restaurantProvider,
              authProvider,
              transformedRestaurant,
            )
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantReviewStats(
                      commentsOfRestaurant,
                      transformedRestaurant,
                    ),
                    const SizedBox(height: 10),
                    const CltHeading(
                      text: "Description",
                      textStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      transformedRestaurant.restaurant.description,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const CltHeading(
                      text: "Branches",
                      textStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildMap(transformedRestaurant),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CltHeading(
                          text: "Reviews",
                          textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (commentsOfRestaurant.isNotEmpty)
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommentsScreen(
                                  restaurantId: widget.restaurantId,
                                ),
                              ),
                            ),
                            child: const Text("See all"),
                          )
                      ],
                    ),
                    const SizedBox(height: 10),
                    CltCreateCommentForm(restaurantId: widget.restaurantId),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              AnimatedCrossFade(
                crossFadeState: commentsOfRestaurant.isNotEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: Duration(
                  milliseconds: commentsOfRestaurant.isEmpty ? 0 : 300,
                ),
                firstChild: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: CltReviewMetaData(
                        commentsOfRestaurant: commentsOfRestaurant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildLatestComments(
                      context,
                      authProvider.token!,
                      commentsOfRestaurant,
                      commentProvider,
                    ),
                  ],
                ),
                secondChild: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [lightOrange, mediumOrange],
                        ).createShader(
                          Rect.fromLTWH(
                            0,
                            0,
                            bounds.width,
                            bounds.height,
                          ),
                        ),
                        child: const Icon(Icons.rate_review, size: 150),
                      ),
                      const Text(
                        "No reviews yet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Be the first to review this restaurant",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildLatestComments(
    BuildContext context,
    String token,
    List<Comment> commentsOfRestaurant,
    CommentProvider commentProvider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(
              min(3, commentsOfRestaurant.length),
              (index) {
                var isOnlyOneLong = commentsOfRestaurant.length == 1;
                var isLastItem =
                    index == 2 || index == commentsOfRestaurant.length - 1;
                return Row(
                  children: [
                    CltCommentCard(
                      comment: commentsOfRestaurant[index],
                      width: commentsOfRestaurant.length == 1
                          ? MediaQuery.of(context).size.width - 32
                          : MediaQuery.of(context).size.width - 56,
                      editComment: () {
                        showDialog(
                          context: context,
                          builder: (_) => CltEditCommentDialog(
                            comment: commentsOfRestaurant[index],
                          ),
                        );
                      },
                      deleteComment: () {
                        commentProvider.deleteComment(
                          token,
                          commentsOfRestaurant[index].id,
                        );
                      },
                    ),
                    SizedBox(
                      width: isOnlyOneLong || isLastItem ? 0 : 12,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  AspectRatio _buildMap(TransformedRestaurant transformedRestaurant) {
    var initialCameraPosition = const CameraPosition(
      target: LatLng(1.3610, 103.8200),
      zoom: 10.25,
    );
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: mediumOrange,
            width: 2,
          ),
        ),
        child: GoogleMap(
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(() {
              return EagerGestureRecognizer();
            }),
          },
          initialCameraPosition: initialCameraPosition,
          markers: transformedRestaurant.restaurant.branches.map(
            (e) {
              return Marker(
                markerId: MarkerId(e.id),
                position: LatLng(e.latitude, e.longitude),
                infoWindow: InfoWindow(
                  title: e.restaurant.name,
                  snippet: e.address,
                ),
              );
            },
          ).toSet(),
        ),
      ),
    );
  }

  Material _buildRestaurantReviewStats(List<Comment> commentsOfRestaurant,
      TransformedRestaurant transformedRestaurant) {
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
                  text: _getAvgRating(commentsOfRestaurant).toStringAsFixed(1),
                ),
                const Text("AVG Rating"),
              ],
            ),
            Column(
              children: [
                CltHeading(
                  text: commentsOfRestaurant.length.toString(),
                ),
                const Text("Reviews"),
              ],
            ),
            Column(
              children: [
                CltHeading(
                  text: transformedRestaurant.usersWhoFavRestaurant.length
                      .toString(),
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

  SliverLayoutBuilder _buildSilverHeader(
    RestaurantProvider restaurantProvider,
    AuthProvider authProvider,
    TransformedRestaurant transformedRestaurant,
  ) {
    var width = MediaQuery.of(context).size.width;
    var currentUser = authProvider.user;
    var isFavoriteByCurrentUser = transformedRestaurant.usersWhoFavRestaurant
        .map((e) => e.id)
        .contains(currentUser?.id);

    return SliverLayoutBuilder(
      builder: (context, offset) {
        var percent = offset.scrollOffset / (width - 52);
        if (offset.scrollOffset >= width - 52) percent = 1;
        var color = Colors.black
            .withBlue((percent * Colors.white.blue).toInt())
            .withGreen((percent * Colors.white.green).toInt())
            .withRed((percent * Colors.white.red).toInt());
        var startPadding = 16 + (72 - 16) * percent;

        return SliverAppBar(
          expandedHeight: width,
          floating: false,
          pinned: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
            icon: Icon(Icons.arrow_back, color: color),
          ),
          actions: [
            IconButton(
              onPressed: () {
                restaurantProvider.toggleRestaurantFavorite(
                  authProvider.token!,
                  widget.restaurantId,
                  currentUser!,
                  !isFavoriteByCurrentUser,
                );
              },
              splashRadius: 20,
              icon: Icon(
                isFavoriteByCurrentUser
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: color,
              ),
            )
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsetsDirectional.only(
              start: startPadding,
              bottom: 16,
            ),
            title: Text(
              transformedRestaurant.restaurant.name,
              style: TextStyle(
                color: color,
              ),
            ),
            background: Image.network(
              transformedRestaurant.restaurant.image!.url,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
