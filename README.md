# dart-flutter-clicktoeat
<img src="android/app/src/main/play_store_512.png" width="200" align="left" />
ClickToEat is a restaurant review app, where users can review on restaurants and interact with other users by liking or disliking their reviews. This project is the flutter version of my ClickToEat V2 and consumes the <a href="https://clicktoeat.nasportfolio.com">ClickToEat API</a>. This project is built for my school project to learn more about animations and testing in flutter.
<br clear="left" />

## Features
- User authentication through the api
- Get restaurant, branch, users, favorite restaurants of users, likes and dislikes data through api
- Create reviews on restaurants
- Create and edit restaurants and their branches
- Favorite restaurants for easier access on home page

## Installation
You can download this project as a zip file or clone this repository. Afterwards, edit the `android/local.properties` file to include your Google Maps API Key.

```properties
MAPS_API_KEY=YOUR_GOOGLE_MAP_API_KEY
```

If you do not have a google maps api key you can follow the instructions [here](https://developers.google.com/maps/documentation/javascript/get-api-key) to get one.

Afterwards you can run the project on a emulator or a physical android device using Android Studio or any code editor which has the flutter plugin.

## Built Using
- [animations: ^2.0.0](https://pub.dev/packages/animations)
- [flutter_svg: ^1.0.0](https://pub.dev/packages/flutter_svg)
- [google_maps_flutter: ^2.1.8](https://pub.dev/packages/google_maps_flutter)
- [http: ^0.13.5](https://pub.dev/packages/http)
- [provider: ^6.0.5](https://pub.dev/packages/provider)
- [shared_preferences: ^2.0.17](https://pub.dev/packages/shared_preferences)
- [image_picker: ^0.8.6+1](https://pub.dev/packages/image_picker)
- [intl: ^0.18.0](https://pub.dev/packages/intl)
- [flutter_speed_dial: ^6.2.0](https://pub.dev/packages/flutter_speed_dial)
- [path_provider: ^2.0.11](https://pub.dev/packages/path_provider)
