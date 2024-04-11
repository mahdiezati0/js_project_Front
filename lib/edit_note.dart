import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/token_manager.dart';
import 'package:note_app/main_page.dart'; // Import MainPage

class EditNote extends StatelessWidget {
  final String memoId;
  final String initialTitle;
  final String initialContent;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  EditNote({
    required this.memoId,
    required this.initialTitle,
    required this.initialContent,
    Key? key,
  }) : super(key: key) {
    titleController.text = initialTitle;
    contentController.text = initialContent;
  }

  Future<void> updateNote(BuildContext context) async {
    final String apiUrl = 'https://mynote.liara.run/Memo/Update';
    final String? token = TokenManager.getToken(); // Get the token from the TokenManager

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // Specify UTF-8 encoding
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'memoId': memoId,
          'title': titleController.text,
          'content': contentController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Note updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to MainPage after successful update
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        // Handle other status codes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating note: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error updating note: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating note. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xffE0E0E0),
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 20),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xff2F2E41),
              size: 38,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, right: 10),
              child: SizedBox(
                height: 41,
                width: 106,
                child: TextButton(
                  style: Theme.of(context).textButtonTheme.style!.copyWith(
                    backgroundColor: MaterialStateProperty.all(Color(0xff00ADB5)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                  ),
                  onPressed: () {
                    updateNote(context);
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Color(0xff2F2E41),
                      fontFamily: "Mulish",
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 341,
                  height: 55,
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Title',
                      fillColor: Color(0xffCCCCCC),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xffCCCCCC)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xffCCCCCC)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xffCCCCCC)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: contentController,
                  maxLines: null, // Allow multiline input for description
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Start typing...',
                    fillColor: Color(0xffCCCCCC),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xffCCCCCC)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xffCCCCCC)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xffCCCCCC)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
