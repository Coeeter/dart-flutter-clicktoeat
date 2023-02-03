import 'package:animations/animations.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:clicktoeat/providers/auth_provider.dart';
import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:clicktoeat/providers/user_provider.dart';
import 'package:clicktoeat/ui/components/typography/clt_heading.dart';
import 'package:clicktoeat/ui/screens/profile/profile_screen.dart';
import 'package:clicktoeat/ui/screens/restaurant/restaurant_details_screen.dart';
import 'package:clicktoeat/ui/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  var query = "";

  @override
  Widget build(BuildContext context) {
    var restaurantProvider = Provider.of<RestaurantProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);
    var currentUser = authProvider.user!;
    var token = authProvider.token!;
    var restaurantList = restaurantProvider.restaurantList
        .where(
          (element) => element.restaurant.name
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList()
      ..sort(
        (a, b) => a.restaurant.name
            .toLowerCase()
            .indexOf(query.toLowerCase())
            .compareTo(
              b.restaurant.name.toLowerCase().indexOf(query.toLowerCase()),
            ),
      );
    var userList = userProvider.users.where((element) {
      return element.username.toLowerCase().contains(
            query.toLowerCase(),
          );
    }).toList();
    userList.sort((a, b) {
      return a.username.toLowerCase().indexOf(query.toLowerCase()).compareTo(
            b.username.toLowerCase().indexOf(query.toLowerCase()),
          );
    });

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        query = "";
                      });
                      _formKey.currentState!.reset();
                    },
                  ),
                  hintText: 'Search for restaurants and users',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CltHeading(text: "Restaurants"),
              const SizedBox(height: 10),
              _buildRestaurantCards(
                restaurantList,
                currentUser,
                restaurantProvider,
                token,
              ),
              if (restaurantList.isEmpty)
                Material(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          "No restaurants found",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          "Try searching for something else",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              const CltHeading(text: "Users"),
              const SizedBox(height: 10),
              _buildUserCards(userList),
              if (userList.isEmpty)
                Material(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          "No users found",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          "Try searching for something else",
                          style: Theme.of(context).textTheme.bodyText1,
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

  Widget _buildUserCards(List<User> userList) {
    return Column(
      children: userList.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OpenContainer(
            closedBuilder: (context, openContainer) {
              return _buildSearchCard(
                leadingImageUrl: e.image?.url,
                title: e.username,
                onTap: openContainer,
              );
            },
            closedColor: ElevationOverlay.colorWithOverlay(
              Theme.of(context).colorScheme.surface,
              Colors.white,
              4,
            ),
            closedElevation: 4,
            openElevation: 0,
            transitionDuration: const Duration(milliseconds: 500),
            transitionType: ContainerTransitionType.fadeThrough,
            openBuilder: (context, _) {
              return ProfileScreen(
                user: e,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRestaurantCards(
    List<TransformedRestaurant> restaurantList,
    User currentUser,
    RestaurantProvider restaurantProvider,
    String token,
  ) {
    return Column(
      children: restaurantList.map(
        (e) {
          var isFavoritedByCurrentUser = e.usersWhoFavRestaurant.any(
            (element) => element.id == currentUser.id,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OpenContainer(
              closedBuilder: (context, openContainer) {
                return _buildSearchCard(
                  leadingImageUrl: e.restaurant.image!.url,
                  title: e.restaurant.name,
                  onTap: openContainer,
                  trailing: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [lightOrange, mediumOrange],
                    ).createShader(bounds),
                    child: IconButton(
                      splashRadius: 20,
                      icon: Icon(
                        isFavoritedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      onPressed: () {
                        restaurantProvider.toggleRestaurantFavorite(
                          token,
                          e.restaurant.id,
                          currentUser,
                          !isFavoritedByCurrentUser,
                        );
                      },
                    ),
                  ),
                );
              },
              closedColor: ElevationOverlay.colorWithOverlay(
                Theme.of(context).colorScheme.surface,
                Colors.white,
                4,
              ),
              closedElevation: 4,
              openElevation: 0,
              transitionDuration: const Duration(milliseconds: 500),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, _) {
                return RestaurantDetailsScreen(
                  restaurantId: e.restaurant.id,
                );
              },
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildSearchCard({
    required String? leadingImageUrl,
    required String title,
    Widget? trailing,
    void Function()? onTap,
  }) {
    var startQueryIndex = title.toLowerCase().indexOf(query.toLowerCase());
    var endQueryIndex = startQueryIndex + query.length;

    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: mediumOrange,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: leadingImageUrl == null
              ? const Icon(Icons.person)
              : ClipOval(
                  child: Image.network(
                    leadingImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: title.substring(
                  0,
                  startQueryIndex,
                ),
              ),
              TextSpan(
                text: title.substring(
                  startQueryIndex,
                  endQueryIndex,
                ),
                style: const TextStyle(color: mediumOrange),
              ),
              TextSpan(
                text: title.substring(endQueryIndex),
              ),
            ],
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
