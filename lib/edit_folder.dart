import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:note_app/token_manager.dart';
import 'main_page.dart';

class EditFolder extends StatelessWidget {
  final String categoryId;
  final String title;

  const EditFolder({Key? key, required this.categoryId, required this.title})
      : super(key: key);

  Future<void> updateFolder(BuildContext context, String categoryId, String title) async {
    final String apiUrl = 'http://78.157.60.108/Category/Update';
    final String? token = TokenManager.getToken();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'categoryId': categoryId,
          'title': title,
        }),
      );

      if (response.statusCode == 202) {
        print('Folder Updated Successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder Edited Successfully', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        // اگر عملیات با خطا مواجه شد
        print('Failed to update folder: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder not edited', textAlign: TextAlign.center),
            backgroundColor: Colors.red, // رنگ قرمز برای عدم موفقیت
          ),
        );
      }
    } catch (error) {
      print('Error updating folder: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextEditingController _titleController = TextEditingController(text: title);

    return Scaffold(
      backgroundColor: Color(0xff2F2E41),
      appBar: AppBar(
        backgroundColor: Color(0xff2F2E41),
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
                      Image.asset("assets/images/create_folder.png"),
                      SizedBox(height: 32),
                      Text(
                        "Edit",
                        style: textTheme.bodyMedium!.copyWith(
                          height: 0,
                          fontSize: 40,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        "Folder",
                        style: textTheme.bodyMedium!.copyWith(
                          height: 0,
                          fontSize: 40,
                          fontFamily: 'Inter',
                          color: Color(0xff00ADB5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 341,
                        height: 55,
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Folder Name',
                            fillColor: Color(0xffffffff),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                              BorderSide(color: Color(0xff3F3D56)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                              BorderSide(color: Color(0xff3F3D56)),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                              BorderSide(color: Color(0xff3F3D56)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: 147,
                    height: 50,
                    child: TextButton(
                      style: Theme.of(context).textButtonTheme.style!.copyWith(
                        backgroundColor:
                        MaterialStateProperty.all(Color(0xff00ADB5)),
                        shadowColor: MaterialStateProperty.all(Colors.black),
                        elevation: MaterialStateProperty.all(20),
                      ),
                      onPressed: () {
                        updateFolder(context, categoryId, _titleController.text);
                      },
                      child: Text(
                        'Save',
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
            ),
          ),
        ),
      ),
    );
  }
}
