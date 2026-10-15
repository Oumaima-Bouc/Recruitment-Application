# Localization & Language Cubit Implementation

## Tasks Completed
1. **Localization Config**:
   - Added `flutter_localizations` to `pubspec.yaml`.
   - Enabled `generate: true`.
   - Created `l10n.yaml` configuration.
   - Created initial `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

2. **Language Cubit**:
   - Created `lib/logic/cubits/language_cubit.dart`.
   - Created `lib/logic/cubits/language_state.dart`.
   - Implemented persistence using `shared_preferences`.

3. **Integration**:
   - Updated `main.dart` to provide `LanguageCubit`.
   - Wrapped `MaterialApp` with `BlocBuilder` to listen for language changes.
   - Added `supportedLocales` and `localizationsDelegates` to `MaterialApp`.

## Verification
- Run `flutter pub get` and `flutter gen-l10n`.
- The app should launch without errors.
- The app defaults to the system locale or English if no saved preference exists.
- Changing the language via `context.read<LanguageCubit>().changeLanguage('ar')` will switch the app to Arabic and enforce RTL layout (handled by `GlobalMaterialLocalizations`).
- Use `app_ar.arb` to test Arabic strings.

## Next Steps
- Sirine needs to implement the Language Switcher UI in Profile/Settings (Epic 8, Task 6).
- Translations need to be added to `app_en.arb` and `app_ar.arb` by Oumaima and Sirine.
