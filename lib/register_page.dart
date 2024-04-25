import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/login_page.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  Future<bool> registerUser(String name, String email, String password) async {
    final url = Uri.parse('https://mynote.liara.run/Account/Register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('Registration successful');
        return true;
      } else {
        print('Registration failed: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Please Check Your Internet Connection: $error');
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

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
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset("assets/images/Register.png"),
                    SizedBox(height: 19),
                    Row(
                      children: [
                        Text(
                          "Register",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 19),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(hintText: "Name"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(hintText: "Email Address"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(hintText: "Password"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+])[A-Za-z\d!@#$%^&*()_+]+$').hasMatch(value)) {
                            return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(hintText: "Confirm Password"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                  width: 340,
                  height: 55,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(350, 70),
                        backgroundColor: Color(0xff00ADB5),
                        shadowColor: Colors.black,
                        elevation: 20,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            _isLoading = true;
                          });
                          String name = nameController.text;
                          String email = emailController.text;
                          String password = passwordController.text;
                          String confirmPassword = confirmPasswordController.text;

                          if (password == confirmPassword) {
                            try {
                              final isSuccess = await registerUser(name, email, password);
                              String message = isSuccess ? 'Registration successful' : 'Registration failed';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } catch (error) {
                              print('FAILED: $error');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error during registration'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Passwords do not match'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                      child: Text(
                        "Already Have An Account?",
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
                SizedBox(height: 58),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
