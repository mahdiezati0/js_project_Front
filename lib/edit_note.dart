import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/token_manager.dart';
import 'package:note_app/main_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class EditNote extends StatefulWidget {
  final String memoId;
  final String initialTitle;
  final String initialContent;
  final String initialColor;
  final String? token = TokenManager.getToken();

  EditNote({
    required this.memoId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialColor,
    Key? key,
  }) : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  List<String> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
    fetchImages();
  }

  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    } else if (hexColor.length != 8) {
      throw FormatException("Invalid hexadecimal color format");
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Future<void> deleteImage(String imageId) async {
    final String apiUrl = 'http://78.157.60.108/Attachment/Delete/$imageId';
    final String? token = TokenManager.getToken();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Image deleted successfully');
      } else {
        print('Failed to delete image: ${response.statusCode}');
        throw Exception('Failed to delete image');
      }
    } catch (error) {
      print('Error deleting image: $error');
      throw Exception('Failed to delete image: $error');
    }
  }


  Future<void> fetchImages() async {
    final String apiUrl = 'http://78.157.60.108/Attachment/Get/';
    final String? token = TokenManager.getToken();
    try {
      final response = await http.get(
        Uri.parse('$apiUrl${widget.memoId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          imageUrls = List<String>.from(json.decode(response.body));
          isLoading = false;
        });
      } else if (response.statusCode == 204) {
        setState(() {
          imageUrls = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No images found for this note.'),
            backgroundColor: Colors.red,
          ),
        );
        print('No images found for this note.');
      } else {
        throw Exception('Failed to load images: ${response.body}');
      }

    } catch (error) {
      print('Error fetching images: $error');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load images. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> updateNote(BuildContext context) async {
    final String apiUrl = 'https://notivous.liara.run/Memo/Update';
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

  Future<void> createPdfAndShare(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${titleController.text}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '${contentController.text}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/${titleController.text}.pdf");
    await file.writeAsBytes(await pdf.save());

    Share.shareFiles([file.path], text: '${titleController.text}');
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
            padding: const EdgeInsets.only(top: 20.0, right: 7),
            child: SizedBox(
              height: 42,
              width: 42,
              child: TextButton(
                style: Theme.of(context).textButtonTheme.style!.copyWith(
                  backgroundColor:
                  MaterialStateProperty.all(Color(0xffE0E0E0)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                ),
                onPressed: () {
                  createPdfAndShare(context);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.share_sharp,
                    color: Color(0xff2F2E41),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 20),
            child: SizedBox(
              height: 41,
              width: 106,
              child: TextButton(
                style: Theme.of(context).textButtonTheme.style!.copyWith(
                  backgroundColor:
                  MaterialStateProperty.all(Color(0xff00ADB5)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    style: TextStyle(
                      color: getColorFromHex(widget.initialColor),
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
                  style: TextStyle(
                    color: getColorFromHex(widget.initialColor),
                  ),
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                  children: imageUrls.map((url) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover, // تنظیم نحوه جا به جایی تصویر
                            width: 100, // تعیین عرض تصویر
                            height: 100, // تعیین ارتفاع تصویر
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // عملیاتی که باید هنگام کلیک بر روی دکمه حذف انجام شود
                            // به عنوان مثال:
                            // deleteImage(imageId); // حذف عکس از API
                            // imageUrls.remove(url); // حذف عکس از لیست نمایش داده شده
                            // setState(() {}); // بروزرسانی ویو
                          },
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 66,
        width: 66,
        decoration: BoxDecoration(
          color: Color(0xff00ADB5),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          width: 50,
          height: 20,
          child: PopupMenuButton<int>(
            color: Color(0xff00ADB5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            offset: Offset(-30, -120),
            icon: Icon(
              Icons.palette_rounded,
              size: 50,
              color: Color(0xff3F3D56),
            ),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xFF000000)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xffffd233)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xff4ecb71)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xff85b6ff)),
                        ),
                      ],
                    ),
                  ),
                  value: 0,
                ),
                PopupMenuItem<int>(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xfffea726)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xffffc700)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xff0fa958)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Do something
                          },
                          child: ColorCircle(color: Color(0xff699bf7)),
                        ),
                      ],
                    ),
                  ),
                  value: 0,
                ),
              ];
            },
          ),
        ),
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  ColorCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
