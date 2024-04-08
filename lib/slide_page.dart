import 'package:flutter/cupertino.dart';
import 'package:note_app/model/slide.dart';
import 'package:flutter/material.dart';
import 'package:note_app/widgets/slide_dots.dart';
import 'package:note_app/widgets/slide_item.dart';
import 'dart:async';
import 'package:note_app/login_page.dart';
import 'package:note_app/register_page.dart';

class SlidePage extends StatefulWidget {
  @override
  State<SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends State<SlidePage> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Color(0xffEEEEEE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: slideList.length,
                      itemBuilder: (ctx, i) => SlideItem(i),
                    ),
                    Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 35),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < slideList.length; i++)
                                if (i == _currentPage)
                                  SlideDots(true)
                                else
                                  SlideDots(false)
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 158,
                        height: 64,
                        child: TextButton(
                          style:
                              Theme.of(context).textButtonTheme.style!.copyWith(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xff222831)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    shadowColor:
                                        MaterialStateProperty.all(Colors.black),
                                    elevation: MaterialStateProperty.all(20),
                                  ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage())),
                          child: Text(
                            "Sign in",
                            style: textTheme.bodyMedium!.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 23,
                      ),
                      SizedBox(
                        width: 158,
                        height: 64,
                        child: TextButton(
                            style: Theme.of(context)
                                .textButtonTheme
                                .style!
                                .copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xff00ADB5)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  shadowColor:
                                      MaterialStateProperty.all(Colors.black),
                                  elevation: MaterialStateProperty.all(20),
                                ),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage())),
                            child: Text(
                              "Register",
                              style: textTheme.bodyMedium!.copyWith(
                                  fontSize: 25, fontWeight: FontWeight.w500),
                            )),
                      )
                    ],
                  ),
                ],
              ),
              // SizedBox(
              //   height: 50,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
