import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/token_manager.dart';
import 'package:note_app/main_page.dart';

class EditNote extends StatefulWidget {
  final String memoId;
  final String initialTitle;
  final String initialContent;

  EditNote({
    required this.memoId,
    required this.initialTitle,
    required this.initialContent,
    Key? key,
  }) : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String? attachmentBase64;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle;
    contentController.text = widget.initialContent;
    fetchAndShowAttachment();
  }

  Future<void> updateNote() async {
    final String apiUrl = 'http://78.157.60.108/Memo/Update';
    final String? token = TokenManager.getToken();

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'memoId': widget.memoId,
          'title': titleController.text,
          'content': contentController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
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
          content: Text('Please Check Your Internet Connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchAndShowAttachment() async {
    final String apiUrl = 'http://78.157.60.108/Attachment/Get/${widget.memoId}';
    final String? token = TokenManager.getToken();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          attachmentBase64 = jsonDecode(response.body) as String;
        });
      } else if (response.statusCode == 204) {
        print('No attachment found for this memo.');
      } else {
        print('Error fetching attachment: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching attachment: $error');
    }
  }

  Future<void> deleteAttachment() async {
    final String apiUrl = 'http://78.157.60.108/Attachment/Delete/${widget.memoId}';
    final String? token = TokenManager.getToken();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 202) {
        setState(() {
          attachmentBase64 = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attachment deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting attachment: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error deleting attachment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Check Your Internet Connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _downloadImageBytes(String base64String) async {
    return base64Decode(base64String);
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 20),
            child: SizedBox(
              height: 41,
              width: 106,
              child: TextButton(
                style: Theme.of(context).textButtonTheme.style!.copyWith(
                  backgroundColor: MaterialStateProperty.all(Color(0xff00ADB5)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                ),
                onPressed: () {
                  updateNote();
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
        ],
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
                  maxLines: null,
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
                SizedBox(height: 20),
                if (attachmentBase64 != null)
                  Column(
                    children: [
                      FutureBuilder<Uint8List>(
                        future: _downloadImageBytes(attachmentBase64!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error loading image');
                          } else if (snapshot.hasData) {
                            return Image.memory(snapshot.data!);
                          } else {
                            return Text('No attachment found');
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          deleteAttachment();
                        },
                        child: Text(
                          "Delete Attachment",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (attachmentBase64 == null)
                  Text('No attachment found for this memo.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
