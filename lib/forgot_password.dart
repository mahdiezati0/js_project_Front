import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  String message = '';
  Color messageColor = Colors.transparent;

  Future<void> sendEmailVerificationCode(String email) async {
    final url = 'https://mynote.liara.run/Account/SendEmailVerificationCode';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'email': email},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle success response
        print('Code sent successfully');
        setState(() {
          message = 'Forget Password Code sent To Your Email';
          messageColor = Colors.green;
        });
      } else if (response.statusCode == 404) {
        // Handle Email Not Found
        print('Email Not Found');
        setState(() {
          message = 'Email Not Found';
          messageColor = Colors.red;
        });
      } else {
        // Handle other status codes
        print('Failed to send code. Status code: ${response.statusCode}');
        setState(() {
          message = 'Failed to send code. Please try again.';
          messageColor = Colors.red;
        });
      }
    } catch (e) {
      // Handle errors
      print('Error: $e');
      setState(() {
        message = 'Error occurred. Please try again later.';
        messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff222831),
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: const Color(0xffEEEEEE),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Image.asset("assets/images/forgetpass.png"),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Enter Your Email",
                            style: textTheme.bodyMedium!.copyWith(
                              fontSize: 28,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 57,
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "Email address",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 340,
                    height: 55,
                    child: TextButton(
                      style: Theme.of(context).textButtonTheme.style!.copyWith(
                        backgroundColor: MaterialStateProperty.all(const Color(0xff00ADB5)),
                        shadowColor: MaterialStateProperty.all(Colors.black),
                        elevation: MaterialStateProperty.all(20),
                      ),
                      onPressed: () {
                        // Call the function to send email verification code
                        print('Sending email verification code...');
                        sendEmailVerificationCode(emailController.text);
                      },
                      child: Text(
                        'Receive The Code',
                        style: textTheme.bodyMedium!.copyWith(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                  Container(
                    color: messageColor,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
