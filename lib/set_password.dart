import 'package:flutter/material.dart';
import 'package:note_app/login_page.dart';

class SetPassword extends StatelessWidget {
  const SetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff222831),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Color(0xffEEEEEE),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Set New",
                          style: textTheme.bodyMedium!.copyWith(
                            height: 0,
                            fontSize: 36,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Password",
                          style: textTheme.bodyMedium!.copyWith(
                            height: 0,
                            fontSize: 40,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: Color(0xff00ADB5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Form(
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: "New password",
                            ),
                          ),
                          SizedBox(
                            height: 26,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Confirm password",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: 340,
                      height: 55,
                      child: TextButton(
                        style: Theme.of(context)
                            .textButtonTheme
                            .style!
                            .copyWith(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xff00ADB5)),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.black),
                              elevation: MaterialStateProperty.all(20),
                            ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage())),
                        child: Text(
                          'Login',
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 23,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 64,
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
