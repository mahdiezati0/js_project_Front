import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:note_app/token_manager.dart';
import 'package:note_app/main_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CreateNote extends StatefulWidget {
  @override
  _CreateNoteState createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  File? _image;

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
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Reminder',
      'It\'s time for your note!',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
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
    backgroundColor:
    MaterialStateProperty.all(Color(0xff00ADB5)),
    shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
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
                SizedBox(height: 20),
                SizedBox(
                  width: 341,
                  height: 55,
                  // child: TextField(
                  //   controller: colorController,
                  //   decoration: InputDecoration(
                  //     filled: true,
                  //     hintText: 'Color',
                  //     fillColor: Color(0xffCCCCCC),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(color: Color(0xffCCCCCC)),
                  //     ),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(color: Color(0xffCCCCCC)),
                  //     ),
                  //     errorBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //       borderSide: BorderSide(color: Color(0xffCCCCCC)),
                  //     ),
                  //   ),
                  // ),
                ),
                SizedBox(height: 20),
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
