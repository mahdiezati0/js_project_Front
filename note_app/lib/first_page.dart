import 'package:flutter/material.dart';
import 'package:note_app/slide_page.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Color(0xffEEEEEE),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 170,
                ),
                Image.asset("assets/images/Welcome.png"),
                SizedBox(
                  height: 170,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 249,
                      height: 55,
                      child: TextButton(
                          style:
                              Theme.of(context).textButtonTheme.style!.copyWith(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xff00ADB5)),
                                    shadowColor:
                                        MaterialStateProperty.all(Colors.black),
                                    elevation: MaterialStateProperty.all(20),
                                  ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SlidePage())),
                          child: Text(
                            'GET STARTED',
                            style: textTheme.bodyMedium!.copyWith(
                                fontSize: 24, color: Color(0xffEEEEEE)),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
