# Velock App

This app allows you to see where your Velock is located and whether it is open or not. You can also view the location history.

## Change Splash Screen (Native)

To change the native splash screen, update the settings in `pubspec.yaml` and generate the new splash screen by running:

```sh
dart run flutter_native_splash:create
```

## Change App Icon

To change the app icon, update the settings in `pubspec.yaml` and generate the new icon by running:

```sh
dart run flutter_launcher_icons
```

## Run the Map

To run the app correctly, you need to add a `.env` file in the root directory with the following variables:

```
MAPBOX_ACCESS_TOKEN='your_access_token_here'
MAPBOX_STYLE='your_map_style_here'
DATABASE_URL='your_firebase_url'
```

## Firebase connection

To run the app correctly, you need to have a valid Firebase project and the `firebase_options.dart` file in the `lib` folder.
