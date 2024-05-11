  import 'package:flutter/material.dart';
  import 'note_folder.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:note_app/token_manager.dart';

  class CreateFolder extends StatelessWidget {
    const CreateFolder({super.key});

    Future<void> _createCategory(String categoryName) async {
      final url = Uri.parse('https://notivous.liara.run/Category/Create');
      final String? token = TokenManager.getToken();
      print('Category Name: $categoryName');

      final Map<String, dynamic> requestBody = {
        'title': categoryName,
      };
      final String jsonBody = jsonEncode(requestBody);
      print('jsonBody Body: $jsonBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonBody,
      );
      print('Response: ${response.body}');


      if (response.statusCode == 202) {
        debugPrint('Category created successfully');
      } else {
        debugPrint('Failed to create category. Error: ${response.statusCode}');
      }
    }

    @override
    Widget build(BuildContext context) {
      TextTheme textTheme = Theme.of(context).textTheme;
      TextEditingController folderNameController = TextEditingController();

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
                          "Create",
                          style: textTheme.bodyMedium!.copyWith(
                            height: 0,
                            fontSize: 40,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          "New Folder",
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
                            controller: folderNameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'folder name',
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
                          backgroundColor: MaterialStateProperty.all(Color(0xff00ADB5)),
                          shadowColor: MaterialStateProperty.all(Colors.black),
                          elevation: MaterialStateProperty.all(20),
                        ),
                        onPressed: () async {
                          await _createCategory(folderNameController.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoteFolder(categoryId: 'your_category_id_here')),
                          );
                        },
                        child: Text(
                          'Add',
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
