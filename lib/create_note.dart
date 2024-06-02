import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:note_app/token_manager.dart';
import 'package:note_app/main_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CreateNote extends StatefulWidget {
  @override
  _CreateNoteState createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  Color selectedColor = Colors.black;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  File? _image;
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }


  @override
  void initState() {
    super.initState();
    _requestPermissions();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _showImmediateNotification();
  }

  void _requestPermissions() async {
    await Permission.notification.request();
  }

  Future<void> addNote(
      BuildContext context, String title, String content, String color) async {
    final String apiUrl = 'http://78.157.60.108/Memo/New';
    final String? token = TokenManager.getToken();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'color': color,
        }),
      );

      print('Sending note: title=$title, content=$content, color=$color');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final memoId = responseData['value'];

        print('Note added successfully with ID: $memoId');

        if (_image != null) {
          print('Uploading image for memo ID: $memoId');
          await uploadImage(memoId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note added successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        handleErrorResponse(response, context);
      }
    } catch (error) {
      print('Error adding note: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Check Your Internet Connection'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> uploadImage(String memoId) async {
    final String apiUrl = 'http://78.157.60.108/Attachment/AttachFile/$memoId';
    final String getIdUrl = 'http://78.157.60.108/Attachment/GetAttachmentIds/$memoId';
    final String? token = TokenManager.getToken();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.files
          .add(await http.MultipartFile.fromPath('attachment', _image!.path));

      print('Request headers: ${request.headers}');
      print('Request files: ${request.files}');

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Image uploaded successfully.');

        // Request to get the attachment ID
        print('Sending request to get attachment IDs');
        print('GET URL: $getIdUrl');
        final getIdResponse = await http.get(
          Uri.parse(getIdUrl),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (getIdResponse.statusCode == 200) {
          final getIdResponseData = jsonDecode(getIdResponse.body);
          final attachmentIds = getIdResponseData['value'];
          print('Attachment IDs: $attachmentIds');
        } else {
          print('Failed to get attachment IDs. Status code: ${getIdResponse.statusCode}');
          print('Response body: ${getIdResponse.body}');
        }
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        response.stream.transform(utf8.decoder).listen((value) {
          print('Response body: $value');
        });
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void handleErrorResponse(http.Response response, BuildContext context) {
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${response.body}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showImmediateNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true, // اضافه کردن ویبره
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Add Note',
      'Please add a new note.',
      platformChannelSpecifics,
      payload: 'add_note',
    );
  }

  Future<void> scheduleNotification(DateTime scheduledDate) async {
    try {
      tz.initializeTimeZones();
      var tehran = tz.getLocation('Asia/Tehran');
      tz.setLocalLocation(tehran);

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      );

      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      var scheduledDateTime = tz.TZDateTime.from(scheduledDate, tehran);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        'It\'s time for your note!',
        scheduledDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        payload: 'reminder',
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }


  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime scheduledDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        await scheduleNotification(scheduledDate);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification scheduled for $scheduledDate'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.alarm,
                        color: Color(0xff2F2E41),
                        size: 24,
                      ),
                      onPressed: () {
                        _selectDateTime(context);
                      },
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: TextButton(
                        style: Theme.of(context)
                            .textButtonTheme
                            .style!
                            .copyWith(
                          backgroundColor: MaterialStateProperty.all(Color(0xff00ADB5)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )),
                        ),
                        onPressed: () {
                          addNote(
                            context,
                            titleController.text,
                            contentController.text,
                            colorController.text,
                          );
                        },
                        child: Text(
                          "Add Note",
                          style: TextStyle(
                            color: Color(0xff2F2E41),
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    style: TextStyle(color: selectedColor),
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
                  style: TextStyle(color: selectedColor),
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
                Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    _image == null
                        ? Text(
                            'No image selected.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Mulish",
                            ),
                          )
                        : Image.file(_image!),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00ACB5),
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      child: Text(
                        'Pick Image',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Mulish",
                        ),
                      ),
                    ),
                  ],
                ),
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
                            setState(() {
                              selectedColor = Color(0xFF000000);
                              colorController.text = colorToHex(selectedColor);
                            });
                          },
                          child: ColorCircle(color: Color(0xFF000000)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = Color(0xffffd233);
                              colorController.text = colorToHex(selectedColor);
                            });
                          },
                          child: ColorCircle(color: Color(0xffffd233)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = Color(0xff4ecb71);
                              colorController.text = colorToHex(selectedColor);
                            });
                          },
                          child: ColorCircle(color: Color(0xff4ecb71)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = Color(0xff85b6ff);
                              colorController.text = colorToHex(selectedColor);
                            });
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
                            setState(() {
                              selectedColor = Color(0xfffea726);
                              colorController.text = colorToHex(selectedColor);
                            });
                          },
                          child: ColorCircle(color: Color(0xfffea726)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = Color(0xffffc700);
                              colorController.text = colorToHex(selectedColor);
                            });
                          },
                          child: ColorCircle(color: Color(0xffffc700)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = Color(0xff0fa958);
                              colorController.text = colorToHex(selectedColor);
                            });
                          },
                          child: ColorCircle(color: Color(0xff0fa958)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = Color(0xff699bf7);
                              colorController.text = colorToHex(selectedColor);
                            });
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
