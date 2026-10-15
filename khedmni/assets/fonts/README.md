This folder is intended to hold font files used by the app.

Please download the following fonts from Google Fonts and place the .ttf files here with the exact filenames used in `pubspec.yaml`:

- Lato Regular  -> Lato-Regular.ttf
  https://fonts.google.com/specimen/Lato

- Lato Bold -> Lato-Bold.ttf
  Select "700" weight

- Source Code Pro Bold -> SourceCodePro-Bold.ttf
  https://fonts.google.com/specimen/Source+Code+Pro

Why not committed here:
- Font files are binary and often large; if you prefer, you can add them to the repo under `assets/fonts/` and commit.

Once the files are present, run:

  flutter pub get
  flutter clean
  flutter run

The app's Theme is configured to use the `Lato` font family by default.
