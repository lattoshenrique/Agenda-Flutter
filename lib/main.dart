import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/loadScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:riquenanucleus/functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationApi.init(initScheduled: true);
  listenNotifications();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

void listenNotifications() =>
    NotificationApi.onNotifications.stream.listen(onClickedNotification);

void onClickedNotification(String? payload) =>
    launchUrl(Uri.parse("tel://${payload!.replaceAll(RegExp(r'[^\w]+'), '')}"));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //remove keyboard on touching anywhere on the screen.
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR')
            ],
            debugShowCheckedModeBanner: false,
            title: 'With ❤ for Nucleus',
            theme: ThemeData(),
            home: const LoadScreen()));
  }
}
