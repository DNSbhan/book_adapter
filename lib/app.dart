import 'package:book_adapter/commands/base_command.dart' as commands;
import 'package:book_adapter/features/library/book_item_details_view.dart';
import 'package:book_adapter/features/library/library_view.dart';
import 'package:book_adapter/features/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:i18n_extension/i18n_widget.dart';

/// The Widget that configures your application.
class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Will be used for controlling the auth state
    /*final baseCommand = */ref.watch(commands.baseCommandProvider);
    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',
      title: 'BookAdapter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
      ],
      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      // home: I18n(child: const LibraryView()),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            final Widget page;
            switch (routeSettings.name) {
              case SettingsView.routeName:
                page = const SettingsView();
                break;
              case BookItemDetailsView.routeName:
                page = const BookItemDetailsView();
                break;
              case LibraryView.routeName:
              default:
                page = const LibraryView();
            }
            return I18n(child: page);
          },
        );
      },
    );
  }
}