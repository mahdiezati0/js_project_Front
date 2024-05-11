import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/token_manager.dart';
import 'package:note_app/main_page.dart';

class NoteFolder extends StatelessWidget {
  final String categoryId;

  const NoteFolder({Key? key, required this.categoryId}) : super(key: key);

  Future<void> saveNote(String title, String content, String token, BuildContext context) async {
    final url = Uri.parse('https://notivous.liara.run/Memo/New');
    final String? token = TokenManager.getToken();

    print('Sending data to API:');
    print('Title: $title');
    print('Content: $content');
    print('Token: $token');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'content': content,
      }),
    );

    print('API Response:');
    print(response.body);

    if (response.statusCode == 201) {
      // Note saved successfully
      final Map<String, dynamic> responseData = json.decode(response.body);
      final memoId = responseData['value'];
      print('Note saved successfully. Memo ID: $memoId');

      // Now, add the note to the category
      await addToCategory(memoId, categoryId, token, context);

    } else {
      print('Failed to save note');
    }
  }

  Future<void> addToCategory(String memoId, String categoryId, String? token, BuildContext context) async {
    final addToCategoryUrl = Uri.parse('https://notivous.liara.run/Memo/AddToCategory?memoId=$memoId&categoryId=$categoryId');
    print('addToCategory*********memoId*********. memoId: $memoId');
    print('addToCategory*********addToCategory*********. categoryId: $categoryId');

    try {
      final response = await http.patch( // تغییر اینجا
        addToCategoryUrl,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Successfully added to category
        print('Added note to category successfully');
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainPage()));
      } else {
        debugPrint('Failed to create category. Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding note to category: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    String title = '';
    String content = '';

    return Scaffold(
      backgroundColor: Color(0xff2F2E41),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xff2F2E41),
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 20),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xffEEEEEE),
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
                    saveNote(title, content, 'your_token_here', context);
                  },
                  child: Text(
                    "Add Note",
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
                    onChanged: (value) {
                      title = value;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Title',
                      fillColor: Color(0xff3F3D56),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xff3F3D56)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xff3F3D56)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xff3F3D56)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    content = value;
                  },
                  maxLines: null, // Allow multiline input for description
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Start typing...',
                    fillColor: Color(0xff3F3D56),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff3F3D56)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff3F3D56)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xff3F3D56)),
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
