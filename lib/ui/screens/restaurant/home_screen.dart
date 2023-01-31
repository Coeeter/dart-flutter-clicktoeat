import 'dart:math';

import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/comment_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/ui/components/clt_restaurant_card.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var restaurantProvider = Provider.of<RestaurantProvider>(context);
    var commentProvider = Provider.of<CommentProvider>(context);

    var currentUser = authProvider.user;

    List<List<TransformedRestaurant>> restaurantList = [];

    for (var i = 0; i < restaurantProvider.restaurantList.length; i += 2) {
      var items = [restaurantProvider.restaurantList[i]];
      if (i + 1 == restaurantProvider.restaurantList.length) {
        restaurantList.add(items);
        break;
      }
      items.add(restaurantProvider.restaurantList[i + 1]);
      restaurantList.add(items);
    }

    var favoriteRestaurants = restaurantProvider.restaurantList
        .where(
          (element) => element.usersWhoFavRestaurant
              .map((e) => e.id)
              .contains(currentUser?.id),
        )
        .toList();

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
      body: restaurantProvider.isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => restaurantProvider.getRestaurants(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "Your Favorite Restaurants"),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 278.4,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: RestaurantCard(
                              toggleFavorite: () {},
                              currentUser: currentUser,
                              commentsOfRestaurant:
                                  commentProvider.commentList.where(
                                (element) {
                                  return element.restaurant.id ==
                                      favoriteRestaurants[index].restaurant.id;
                                },
                              ).toList(),
                              transformedRestaurant: favoriteRestaurants[index],
                            ),
                          );
                        },
                        itemCount: min(favoriteRestaurants.length, 5),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "Featured Restaurants"),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 278.4,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: RestaurantCard(
                              toggleFavorite: () {},
                              currentUser: currentUser,
                              commentsOfRestaurant:
                                  commentProvider.commentList.where(
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
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                      child: CltHeading(text: "All Restaurants"),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: RestaurantCard(
                                toggleFavorite: () {},
                                currentUser: currentUser,
                                commentsOfRestaurant: commentProvider
                                    .commentList
                                    .where((element) {
                                  return element.restaurant.id ==
                                      restaurantList[index][0].restaurant.id;
                                }).toList(),
                                transformedRestaurant: restaurantList[index][0],
                              ),
                            ),
                            Expanded(
                              child: restaurantList[index].length == 1
                                  ? Container()
                                  : RestaurantCard(
                                      toggleFavorite: () {},
                                      currentUser: currentUser,
                                      commentsOfRestaurant: commentProvider
                                          .commentList
                                          .where((element) {
                                        return element.restaurant.id ==
                                            restaurantList[index][1]
                                                .restaurant
                                                .id;
                                      }).toList(),
                                      transformedRestaurant:
                                          restaurantList[index][1],
                                    ),
                            ),
                          ],
                        );
                      },
                      itemCount: restaurantList.length,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
