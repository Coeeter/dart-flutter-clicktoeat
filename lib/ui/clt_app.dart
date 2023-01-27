import 'package:clicktoeat/providers/restaurant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CltApp extends StatelessWidget {
  const CltApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickToEat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello world"),
        actions: [
          IconButton(
            onPressed: () => restaurantProvider.getRestaurants(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: restaurantProvider.isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          restaurantProvider.restaurantList[index].image!.url,
                        ),
                      ),
                      Text(restaurantProvider.restaurantList[index].name),
                    ],
                  ),
                );
              },
              itemCount: restaurantProvider.restaurantList.length,
            ),
    );
  }
}
