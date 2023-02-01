import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:flutter/material.dart';
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
    var authProvider = Provider.of<AuthProvider>(context);
    var width = MediaQuery.of(context).size.width;
    var currentUser = authProvider.user;
    var transformedRestaurant = restaurantProvider.restaurantList.firstWhere(
      (element) => element.restaurant.id == widget.restaurantId,
    );
    var isFavoriteByCurrentUser = transformedRestaurant.usersWhoFavRestaurant
        .map((e) => e.id)
        .contains(currentUser?.id);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverLayoutBuilder(builder: (context, offset) {
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
            })
          ];
        },
        body: Container(),
      ),
    );
  }
}
