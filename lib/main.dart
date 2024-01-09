import 'package:abg_utils/abg_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ondemandservice/ui/theme.dart';
import 'model/model.dart';
import 'ui/main.dart';
import 'ui/start/splash.dart';
import 'package:ondemandservice/ui/start/onboard.dart';
import 'ui/strings.dart';
import 'package:provider/provider.dart';

bool enableGooglePay = true;
bool enableApplePay = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await getTheme();
  await getLocalSettings();
  theme = AppTheme(localSettings.darkMode);

//  needStat = true;
  initStat("customer2", "1.3.0.10");

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainModel()),
        ChangeNotifierProvider(create: (_) => LanguageChangeNotifierProvider()),
      ],
      child: OnDemandApp()
  ));
}

class OnDemandApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: strings.get(0),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
        const Locale('de'),
        const Locale('es'),
        const Locale('fr'),
        const Locale('ar'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('hi'),
      ],
      locale: Provider.of<LanguageChangeNotifierProvider>(context, listen: true).currentLocale,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (BuildContext context) => SplashScreen(),
        '/main': (BuildContext context) => MainScreen(),
        '/onboard': (BuildContext context) => OnBoardingScreen(),
      },
    );
  }
}

class LanguageChangeNotifierProvider with ChangeNotifier, DiagnosticableTreeMixin {

  Locale  _currentLocale = Locale(strings.locale);

  Locale get currentLocale => _currentLocale;

  void changeLocale(String _locale){
    _currentLocale = Locale(_locale);
    notifyListeners();
  }
}