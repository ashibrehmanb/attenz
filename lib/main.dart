import 'package:attenz/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        fontFamily: 'Product-Sans',
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.green,
          ),
        ),
        primarySwatch: Colors.green,
        backgroundColor: Colors.white,
      ),
      home: const //ScreenHome(),
          ScreenSplash(),
    );
  }
}
