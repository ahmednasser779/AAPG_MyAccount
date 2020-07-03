import 'package:aapg_myaccount_flutter/screens/home/activity_feed.dart';
import 'package:aapg_myaccount_flutter/screens/home/home.dart';
import 'package:aapg_myaccount_flutter/screens/pages/inbox.dart';
import 'package:aapg_myaccount_flutter/shared/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'services/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  Route routes(RouteSettings settings) {
    if (settings.name.contains("/activity_feed")) {
      return MaterialPageRoute(
        builder: (_) => ActivityFeed(),
      );
    } else if (settings.name.contains("/inbox")) {
      return MaterialPageRoute(
        builder: (_) => Inbox(),
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => Home(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
        title: 'AAPG MyAccount',
        onGenerateRoute: routes,
        navigatorKey: navigatorKey,
        theme: ThemeData(
            primaryColor: Color(0xFF8B1122),
            primarySwatch: Colors.red,
            accentColor: Colors.yellow[800]),
      ),
    );
  }
}
