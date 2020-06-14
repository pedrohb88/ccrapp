import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ccrapp/components/loader.dart';
import 'package:ccrapp/screens/register_screen/register_screen.dart';
import 'package:ccrapp/screens/main_screen/main_screen.dart';

import 'package:ccrapp/models/user.dart';
import 'package:ccrapp/models/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParadaSegura',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final User user = User();
  bool _loading = true;

  void _logUserIn() async {
    final storage = new FlutterSecureStorage();
    final token = await storage.read(key: 'auth-token');
    if (token != null) {
      final result = await Api().get(route: '/user', headers: {
        "x-auth": token,
      });

      if (result != null) {
        final body = result['body'];
        user.update(
          isLogged: true,
          name: body['name'],
          phone: body['phone'],
        );
      }
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    /*final s = FlutterSecureStorage();
    s.deleteAll();*/

    _logUserIn();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider<User>(
          create: (context) => user,
          child: Consumer<User>(
            builder: (context, user, child) {
              if (_loading)
                return Loader(fullScreen: true);
              else if (user.isLogged)
                return MainScreen();
              else
                return RegisterScreen();
            },
          ),
        ),
      ),
    );
  }
}
