import 'package:animations/animations.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/clt_restaurant_card.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/auth/auth_screen.dart';
import 'package:clicktoeat/ui/screens/restaurant/add_update_restaurant_screen.dart';
import 'package:clicktoeat/ui/screens/restaurant/restaurant_details_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var restaurantProvider = Provider.of<RestaurantProvider>(context);
    var commentProvider = Provider.of<CommentProvider>(context);

    var currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser == null
              ? "Loading..."
              : "Welcome, ${authProvider.user!.username}",
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var provider = Provider.of<AuthProvider>(context, listen: false);
              await provider.logOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(animate: false),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: const AddRestaurantButton(),
      body: restaurantProvider.isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                restaurantProvider.getRestaurants();
                commentProvider.getComments();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "Your Favorite Restaurants"),
                    ),
                    FavoriteRestaurantsSection(
                      restaurantProvider: restaurantProvider,
                      authProvider: authProvider,
                      commentProvider: commentProvider,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "Featured Restaurants"),
                    ),
                    FeaturedRestaurantSection(
                      restaurantProvider: restaurantProvider,
                      authProvider: authProvider,
                      commentProvider: commentProvider,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "Restaurants near you"),
                    ),
                    RestaurantsNearYouSection(
                      restaurantProvider: restaurantProvider,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "All Restaurants"),
                    ),
                    AllRestaurantsSection(
                      restaurantProvider: restaurantProvider,
                      authProvider: authProvider,
                      commentProvider: commentProvider,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class AddRestaurantButton extends StatelessWidget {
  const AddRestaurantButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      transitionDuration: const Duration(milliseconds: 650),
      closedElevation: 4,
      closedColor: mediumOrange,
      closedShape: const CircleBorder(),
      closedBuilder: (context, openContainer) => Tooltip(
        message: "Add Restaurant",
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: openContainer,
          child: const SizedBox(
            height: 56,
            width: 56,
            child: Center(
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
      openBuilder: (context, closeContainer) => AddRestaurantScreen(
        navigateBack: closeContainer,
      ),
    );
  }
}

class RestaurantsNearYouSection extends StatelessWidget {
  final RestaurantProvider restaurantProvider;

  const RestaurantsNearYouSection({
    Key? key,
    required this.restaurantProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var initialCameraPosition = const CameraPosition(
      target: LatLng(1.3610, 103.8200),
      zoom: 10.25,
    );

    var branches = restaurantProvider.restaurantList
        .map((e) => e.restaurant.branches)
        .expand((e) => e)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      child: AspectRatio(
        aspectRatio: 1,
        child: GoogleMap(
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          initialCameraPosition: initialCameraPosition,
          markers: branches
              .map(
                (e) => Marker(
                  markerId: MarkerId(e.id),
                  position: LatLng(
                    e.latitude,
                    e.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: e.restaurant.name,
                    snippet: e.address,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RestaurantDetailsScreen(
                          restaurantId: e.restaurant.id,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toSet(),
        ),
      ),
    );
  }
}

class FeaturedRestaurantSection extends StatelessWidget {
  const FeaturedRestaurantSection({
    Key? key,
    required this.restaurantProvider,
    required this.authProvider,
    required this.commentProvider,
  }) : super(key: key);

  final RestaurantProvider restaurantProvider;
  final AuthProvider authProvider;
  final CommentProvider commentProvider;

  @override
  Widget build(BuildContext context) {
    var currentUser = authProvider.user;

    var featuredRestaurants = restaurantProvider.restaurantList
      ..sort((a, b) {
        var commentsOfA = commentProvider.commentList.where((element) {
          return element.restaurant.id == a.restaurant.id;
        });
        var commentsOfB = commentProvider.commentList.where((element) {
          return element.restaurant.id == b.restaurant.id;
        });

        var totalRatingOfA = commentsOfA.fold<int>(0, (value, element) {
          return value + element.rating;
        });
        var totalRatingOfB = commentsOfB.fold<int>(0, (value, element) {
          return value + element.rating;
        });

        var averateRatingOfA =
            commentsOfA.isEmpty ? 0 : totalRatingOfA / commentsOfA.length;
        var averateRatingOfB =
            commentsOfB.isEmpty ? 0 : totalRatingOfB / commentsOfB.length;
        return averateRatingOfB.compareTo(averateRatingOfA);
      });

    return SizedBox(
      width: double.infinity,
      height: 278.4,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: CltRestaurantCard(
              toggleFavorite: (toAddToFav, restaurantId) {
                restaurantProvider.toggleRestaurantFavorite(
                  authProvider.token!,
                  restaurantId,
                  currentUser!,
                  toAddToFav,
                );
              },
              currentUser: currentUser,
              commentsOfRestaurant: commentProvider.commentList.where(
                (element) {
                  return element.restaurant.id ==
                      featuredRestaurants[index].restaurant.id;
                },
              ).toList(),
              transformedRestaurant: featuredRestaurants[index],
            ),
          );
        },
        itemCount: 5,
      ),
    );
  }
}

class FavoriteRestaurantsSection extends StatelessWidget {
  const FavoriteRestaurantsSection({
    Key? key,
    required this.restaurantProvider,
    required this.authProvider,
    required this.commentProvider,
  }) : super(key: key);

  final RestaurantProvider restaurantProvider;
  final AuthProvider authProvider;
  final CommentProvider commentProvider;

  @override
  Widget build(BuildContext context) {
    var currentUser = authProvider.user;

    var favoriteRestaurants = restaurantProvider.restaurantList
        .where(
          (element) => element.usersWhoFavRestaurant
              .map((e) => e.id)
              .contains(currentUser?.id),
        )
        .toList()
      ..sort((a, b) => a.restaurant.name.compareTo(b.restaurant.name));

    return SizedBox(
      width: double.infinity,
      height: 278.4,
      child: favoriteRestaurants.isEmpty
          ? const EmptyFavoritesContent()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: CltRestaurantCard(
                    toggleFavorite: (toAddToFav, restaurantId) {
                      restaurantProvider.toggleRestaurantFavorite(
                        authProvider.token!,
                        restaurantId,
                        currentUser!,
                        toAddToFav,
                      );
                    },
                    commentsOfRestaurant: commentProvider.commentList
                        .where(
                          (element) =>
                              element.restaurant.id ==
                              favoriteRestaurants[index].restaurant.id,
                        )
                        .toList(),
                    currentUser: currentUser,
                    transformedRestaurant: favoriteRestaurants[index],
                  ),
                );
              },
              itemCount: favoriteRestaurants.length,
            ),
    );
  }
}

class EmptyFavoritesContent extends StatelessWidget {
  const EmptyFavoritesContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [lightOrange, mediumOrange],
            ).createShader(
              Rect.fromLTWH(
                0,
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          child: const Icon(
            Icons.heart_broken,
            size: 200,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Text(
            "Wow such empty...\nTry favoriting a restaurant now!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
        ),
      ],
    );
  }
}

class AllRestaurantsSection extends StatelessWidget {
  final RestaurantProvider restaurantProvider;
  final AuthProvider authProvider;
  final CommentProvider commentProvider;

  const AllRestaurantsSection({
    Key? key,
    required this.restaurantProvider,
    required this.authProvider,
    required this.commentProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentUser = authProvider.user;

    List<List<TransformedRestaurant>> restaurantList = [];

    for (var i = 0; i < restaurantProvider.restaurantList.length; i += 2) {
      restaurantList.add(
        restaurantProvider.restaurantList.skip(i).take(2).toList(),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Row(
          children: [
            ...restaurantList[index]
                .map(
                  (e) => Expanded(
                    child: CltRestaurantCard(
                      toggleFavorite: (toAddToFav, restaurantId) {
                        restaurantProvider.toggleRestaurantFavorite(
                          authProvider.token!,
                          restaurantId,
                          currentUser!,
                          toAddToFav,
                        );
                      },
                      commentsOfRestaurant: commentProvider.commentList
                          .where(
                            (element) =>
                                element.restaurant.id == e.restaurant.id,
                          )
                          .toList(),
                      currentUser: currentUser,
                      transformedRestaurant: e,
                    ),
                  ),
                )
                .toList(),
            if (restaurantList[index].length == 1) Expanded(child: Container()),
          ],
        );
      },
      itemCount: restaurantList.length,
    );
  }
}
