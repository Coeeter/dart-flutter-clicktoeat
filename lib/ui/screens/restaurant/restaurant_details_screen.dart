import 'dart:math';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/domain/comment/comment.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/buttons/clt_gradient_button.dart';
import 'package:clicktoeat/ui/components/clt_comment_card.dart';
import 'package:clicktoeat/ui/components/clt_review_meta_data.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
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
                      onPressed: () {}, // TODO: Navigate to all reviews acreen
                      child: const Text("See all"),
                    )
                ],
              ),
              const SizedBox(height: 10),
              ReviewForm(restaurantId: widget.restaurantId),
              const SizedBox(height: 10),
              AnimatedCrossFade(
                crossFadeState: commentsOfRestaurant.isNotEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
                firstChild: Column(
                  children: [
                    CltReviewMetaData(
                      commentsOfRestaurant: commentsOfRestaurant,
                    ),
                    const SizedBox(height: 10),
                    _buildLatestComments(commentsOfRestaurant, context),
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
    List<Comment> commentsOfRestaurant,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          min(3, commentsOfRestaurant.length),
          (index) {
            return Row(
              children: [
                CltCommentCard(
                  comment: commentsOfRestaurant[index],
                  width: commentsOfRestaurant.length == 1
                      ? MediaQuery.of(context).size.width - 32
                      : MediaQuery.of(context).size.width - 56,
                ),
                SizedBox(
                  width: commentsOfRestaurant.length == 1 ||
                          index == 2 ||
                          index == commentsOfRestaurant.length - 1
                      ? 0
                      : 12,
                ),
              ],
            );
          },
        ),
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

class ReviewForm extends StatefulWidget {
  final String restaurantId;

  const ReviewForm({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  String review = "";
  int rating = 0;
  String? reviewError;
  String? ratingError;
  bool isLoading = false;

  bool _validateRating() {
    if (rating != 0) return true;
    setState(() {
      ratingError = "Rating required!";
    });
    return false;
  }

  void submit() async {
    FocusScope.of(context).unfocus();
    var isReviewValid = _formKey.currentState!.validate();
    var isRatingValid = _validateRating();
    if (!isReviewValid || !isRatingValid) return;
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      var commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );
      var token = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).token!;
      await commentProvider.createComment(
        token,
        widget.restaurantId,
        review,
        rating,
      );
    } on FieldException catch (e) {
      var reviewError = e.fieldErrors.where(
        (element) => element.field == "review",
      );
      var ratingError = e.fieldErrors.where(
        (element) => element.field == "rating",
      );
      if (reviewError.isNotEmpty) {
        setState(() {
          this.reviewError = reviewError.first.error;
        });
      }
      if (ratingError.isNotEmpty) {
        setState(() {
          this.ratingError = ratingError.first.error;
        });
      }
      return;
    } on DefaultException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error)),
      );
      return;
    } finally {
      _formKey.currentState!.reset();
      setState(() {
        isLoading = false;
        review = "";
        rating = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: "Review",
              border: const OutlineInputBorder(),
              errorText: reviewError,
            ),
            onChanged: (_) {
              if (reviewError == null) return;
              setState(() {
                reviewError = null;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Review required!";
              }
              return null;
            },
            onSaved: (value) {
              setState(() {
                review = value!;
              });
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) {
                  return LinearGradient(
                    colors: ratingError != null
                        ? [Colors.red, Colors.red]
                        : [lightOrange, mediumOrange],
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) {
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                ratingError = null;
                                if (rating == index + 1 && rating != 1) {
                                  rating--;
                                  return;
                                }
                                rating = index + 1;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            icon: Icon(
                              rating >= index + 1
                                  ? Icons.star
                                  : Icons.star_border_outlined,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CltGradientButton(
                  onClick: submit,
                  isLoading: isLoading,
                  text: "Submit",
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (ratingError != null)
            Text(
              ratingError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }
}
