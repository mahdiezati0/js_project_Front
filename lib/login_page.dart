import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/register_page.dart';
import 'package:note_app/forgot_password.dart';
import 'package:note_app/main_page.dart';
import 'package:note_app/token_manager.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key});

  Future<void> loginUser(BuildContext context, String email, String password) async {
    final String apiUrl = 'https://mynote.liara.run/Account/Login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['isSuccess']) {
        print('Login was successful!');
        if (responseBody['value'] != null &&
            responseBody['value']['token'] != null) {
          String token = responseBody['value']['token'];
          TokenManager.setToken(token); // Set the token using the TokenManager
          print('Data: $token'); // Print the token here

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login Successful'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to main_page.dart after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      } else {
        final errorMessage = response.statusCode == 401
            ? 'Username or Password was Wrong'
            : 'Login failed';

        print(errorMessage);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    catch (error) {
      print('Error during login: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during login. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

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
                        "WELCOME BACK",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(
                        height: 27,
                      ),
                      Image.asset(
                        "assets/images/login.png",
                        height: 150,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Sign in",
                            style: textTheme.bodyMedium!.copyWith(
                              fontSize: 32,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "Email address",
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(hintText: "Password"),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(


                        onPressed:()=>Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context)=>ForgotPassword())
                        ),

                        child: Text(
                          "I Forgot My Password.",
                          style: TextStyle(
                            fontFamily: "roboto",
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          shape: MaterialStateProperty.all(null),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 26,
                  ),
                  SizedBox(
                    width: 340,
                    height: 55,
                    child: TextButton(
                      style: Theme.of(context).textButtonTheme.style!.copyWith(
                        backgroundColor: MaterialStateProperty.all(Color(0xff00ADB5)),
                        shadowColor: MaterialStateProperty.all(Colors.black),
                        elevation: MaterialStateProperty.all(20),
                      ),
                      onPressed: () {
                        loginUser(
                          context,
                          emailController.text,
                          passwordController.text,
                        );
                      },

                      child: Text(
                        'Sign in',
                        style: textTheme.bodyMedium!.copyWith(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 14,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: Text(
                          "I Don't Have An Account Yet.",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "roboto",
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          shape: MaterialStateProperty.all(null),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 64,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
