import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:note_app/first_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    requestNotificationPermission(); // درخواست دسترسی به نوتیفیکیشن‌ها
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff222831),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: "Schyler",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xffFFFFFF),
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 5,
              color: Color(0xff00ADB5),
            ),
          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 4,
              color: Colors.red.shade900,
            ),
          ),
          hintStyle: TextStyle(color: Color(0xff808080)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xffFFFFFF)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
            ),
          ),
        ),
      ),
      home: const FirstPage(),
    );
  }
}

// درخواست دسترسی به نوتیفیکیشن‌ها
Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}
