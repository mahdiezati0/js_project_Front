import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/create_folder.dart';
import 'package:note_app/edit_folder.dart';
import 'package:note_app/create_note.dart';
import 'package:note_app/token_manager.dart';
import 'package:note_app/edit_note.dart';
import 'package:note_app/note_folder.dart';
import 'package:note_app/show_folder.dart';
import 'setting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> folders = [];
  bool isDeletingMode = false;
  Set<int> selectedNotes = {};
  String? _selectedOption;
  bool _isSearchBarVisible = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedOption = 'date';
    fetchNoteData();
    fetchFolderData();
  }

  void _initializeNotifications() {
    // Define the on notification pressed event
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          if (payload != null) {
            // Handle notification payload here
            if (payload == 'reminder') {
              // Handle the reminder notification
              // For example, navigate to the CreateNote page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateNote()),
              );
            }
          }
        });
  }


  Future<void> _fetchDataWithSearch(String query) async {
    final String searchUrl = 'http://78.157.60.108/Memo/Search?Parameter=$query&SortType=1';

    try {
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${TokenManager.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          notes = List<Map<String, dynamic>>.from(responseData['value']);
        });
        // Log the successful search
        print('Search operation successful.');
      } else {
        print('Error fetching search results: ${response.statusCode}');
        _showSnackBar('Error fetching search results', Colors.red);
      }
    } catch (error) {
      print('Error fetching search results: $error');
      _showSnackBar('Please Check Your Internet Connection', Colors.red);
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      _fetchDataWithSearch(query);
    } else {
      fetchNoteData();
    }
  }


  Future<void> fetchNoteData() async {
    final String notesUrl = 'http://78.157.60.108/Memo/Get';

    try {
      final notesResponse = await http.get(
        Uri.parse(notesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${TokenManager.getToken()}',
        },
      );

      if (notesResponse.statusCode == 200) {
        final notesData = json.decode(notesResponse.body);

        setState(() {
          notes = List<Map<String, dynamic>>.from(notesData['value']);
        });
      } else {
        print('Error fetching notes data: ${notesResponse.statusCode}');
        _showSnackBar('Error fetching notes data', Colors.red);
      }
    } catch (error) {
      print('Error fetching notes data: $error');
      _showSnackBar('Please Check Your Internet Connection', Colors.red);
    }
  }

  Future<void> fetchFolderData() async {
    final String foldersUrl = 'http://78.157.60.108/Category/Get';

    try {
      final foldersResponse = await http.get(
        Uri.parse(foldersUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${TokenManager.getToken()}',
        },
      );

      if (foldersResponse.statusCode == 200) {
        final foldersData = json.decode(foldersResponse.body);

        setState(() {
          folders = List<Map<String, dynamic>>.from(foldersData['value']);
        });
      } else {
        print('Error fetching folders data: ${foldersResponse.statusCode}');
        _showSnackBar('Error fetching folders data', Colors.red);
      }
    } catch (error) {
      print('Error fetching folders data: $error');
      _showSnackBar('Please Check Your Internet Connection', Colors.red);
    }
  }

  Future<void> fetchDataWithSort(int sortType) async {
    final String searchUrl =
        'http://78.157.60.108/Memo/Search?SortType=$sortType';

    try {
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${TokenManager.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          notes = List<Map<String, dynamic>>.from(responseData['value']);
        });
        print('Sort operation successful');
      } else {
        print('Error fetching sorted data: ${response.statusCode}');
        _showSnackBar('Error fetching sorted data', Colors.red);
      }
    } catch (error) {
      print('Error fetching sorted data: $error');
      _showSnackBar('Please Check Your Internet Connection', Colors.red);
    }
  }

  Future<void> deleteSelectedFolders() async {
    final String apiUrl = 'http://78.157.60.108/Category/Delete/';
    bool isDeleted = false;

    try {
      final List<int> selectedFolderIndices = selectedNotes.toList();
      await Future.wait(selectedFolderIndices.map((int index) async {
        final folder = folders[index];
        final response = await http.delete(
          Uri.parse('$apiUrl${folder['id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${TokenManager.getToken()}',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            folders.removeAt(index);
            isDeleted = true;
          });
        } else {
          print('Error deleting folder: ${response.statusCode}');
        }
      }));

      setState(() {
        selectedNotes.clear();
      });

    } catch (error) {
      print('Error deleting folders: $error');
    }

    if (isDeleted) {
      _showSnackBar('Folder Deleted successful.', Colors.green);
    } else {
      _showSnackBar('Error in Delting Folder.', Colors.red);
    }
  }


  Future<void> deleteSelectedNotes() async {
    final String apiUrl = 'http://78.157.60.108/Memo/Delete/';
    bool isDeleted = false;

    try {
      final List<int> selectedIndices = selectedNotes.toList();
      await Future.wait(selectedIndices.map((int index) async {
        final note = notes[index - folders.length]; // Adjust index for notes
        final response = await http.delete(
          Uri.parse('$apiUrl${note['id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${TokenManager.getToken()}',
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            notes.removeAt(index - folders.length);
            isDeleted = true;
          });
        } else {
          print('Error deleting note: ${response.statusCode}');
        }
      }));

      setState(() {
        selectedNotes.clear();
      });

    } catch (error) {
      print('Error deleting notes: $error');
    }

    if (isDeleted) {
      _showSnackBar('Note Deleted successful.', Colors.green);
    } else {
      _showSnackBar('Error In Deleting Note', Colors.red);
    }
  }

  void toggleNoteSelection(int index) {
    setState(() {
      if (selectedNotes.contains(index)) {
        selectedNotes.remove(index);
      } else {
        selectedNotes.add(index);
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        backgroundColor: Color(0xffE0E0E0),
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                    onPressed: () {
                      if (isDeletingMode) {
                        // این قسمت برای وضعیت حذف در صفحه است که همه عناصر انتخاب شده را پاک می‌کند و از حالت حذف خارج می‌شود
                        setState(() {
                          selectedNotes.clear();
                          isDeletingMode = false;
                        });
                      } else {
                        // این قسمت برای وقتی که در حالت حذف نیستیم و روی آیکون کلیک می‌کنیم، به صفحه تنظیمات منتقل می‌شویم
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingPage()),
                        );
                      }
                    },

                    icon: Icon(
                      isDeletingMode ? Icons.close : Icons.settings_rounded,
                      color: Color(0xff2F2E41),
                    ),
                    iconSize: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Padding(
          padding:
          const EdgeInsets.only(left: 0, top: 30, right: 10, bottom: 10),
          child: IconButton(
            icon: Icon(
              _isSearchBarVisible ? Icons.close : Icons.search_rounded,
              color: Color(0xff2F2E41),
            ),
            iconSize: 42,
            color: Color(0xff2F2E41),
            onPressed: () {
              setState(() {
                _isSearchBarVisible = !_isSearchBarVisible;
              });
            },
          ),
        ),
        actions: [
          _isSearchBarVisible
              ? Padding(
            padding: const EdgeInsets.only(top: 15.0, right: 18),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 40,
                width: 250,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'search...',
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
                  style: TextStyle(color: Colors.black),
                  onChanged: _onSearch,
                ),
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.only(top: 22.0, right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 50,
                width: 160,
                child: _isSearchBarVisible
                    ? SizedBox()
                    : Image.asset(
                  "assets/images/LogoText.png",
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0),
            child: Container(
              color: Color(0xff3F3D56),
              height: 3.3,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 0.0, top: 0.0),
                child: SizedBox(
                  width: 70,
                  height: 30,
                  child: PopupMenuButton(
                    color: Color(0xff2F2E41),
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    offset: Offset(0, 28),
                    child: Row(
                      children: [
                        Text(
                          'Sort By',
                          style: TextStyle(
                              color: Color(0xff707070),
                              fontSize: 11.2,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Mulish"),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Icon(
                          Icons.arrow_circle_down_rounded,
                          color: Color(0xff707070),
                          size: 14,
                        ),
                      ],
                    ),
                    onSelected: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                      print('Selected: $value');
                      int sortType;
                      switch (value) {
                        case 'name':
                          sortType = 2;
                          break;
                        case 'date':
                          sortType = 1;
                          break;
                        default:
                          sortType = 1;
                          break;
                      }
                      fetchDataWithSort(sortType);
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 'name',
                          child: Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
                                    value: 'name',
                                    groupValue: _selectedOption,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Mulish"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'date',
                          child: Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
                                    value: 'date',
                                    groupValue: _selectedOption,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Date ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Mulish"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                color: Color(0xff00ADB5),
                onRefresh: () async {
                  await fetchNoteData();
                  fetchFolderData();
                },
                child: ListView.builder(
                itemCount: notes.length + folders.length,
                itemBuilder: (context, index) {
                  if (index < folders.length) {
                    final folder = folders[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Color(0xFF00ACB5),
                        child: ListTile(
                          leading: Image.asset(
                            "assets/images/Folder1.png",
                            width: 24,
                            height: 24,
                          ),
                          title: Row(
                            children: [
                              Text(
                                folder['name'] ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditFolder(
                                        categoryId: folders[index]['id'],
                                        title: folders[index]['name'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NoteFolder(categoryId: folders[index]['id']),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowFolder(
                                  categoryId: folders[index]['id'],
                                  title: folders[index]['name'],
                                ),
                              ),
                            );
                          },
                          trailing: isDeletingMode
                              ? Checkbox(
                            value: selectedNotes.contains(index),
                            onChanged: (value) {
                              toggleNoteSelection(index);
                            },
                            checkColor: Colors.white,
                            activeColor: Colors.red,
                          )
                              : null,
                        ),
                      ),
                    );

                  } else {
                    final note = notes[index - folders.length];
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          isDeletingMode = true;
                          selectedNotes.add(index);
                        });
                      },
                      onTap: () {
                        if (isDeletingMode) {
                          toggleNoteSelection(index);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNote(
                                memoId: note['id'],
                                initialTitle: note['title'] ?? '',
                                initialContent: note['content'] ?? '',
                                initialColor:note['color']??'',
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              note['title'] ?? '',
                              style: TextStyle(
                                color: Color(0xFF00ACB4),
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            subtitle: Text(
                              note['content'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isDeletingMode
                                ? Checkbox(
                              value: selectedNotes.contains(index),
                              onChanged: (value) {
                                toggleNoteSelection(index);
                              },
                              checkColor: Colors.white,
                              activeColor: Colors.red,
                            )
                                : null,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),

              ),
            ),
          ),
        ],
      ),

      floatingActionButton: isDeletingMode
          ? FloatingActionButton(
        onPressed: () {
          deleteSelectedFolders();
          deleteSelectedNotes();
        },
        child: Icon(
          Icons.delete,
          size: 30,
        ),
        backgroundColor: Colors.red,
      )
          : Container(
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
          child: PopupMenuButton(
            color: Color(0xff00ADB5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            offset: Offset(-50, -140),
            icon: Icon(
              Icons.add,
              size: 50,
              color: Color(0xff3F3D56),
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      Icons.add_box_rounded,
                      size: 35,
                      color: Color(0xff3F3D56),
                    ),
                    title: Text("NOTE",
                        style: TextStyle(
                            color: Color(0xff2F2E41),
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                  ),
                  value: 'note',
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      Icons.add_box_rounded,
                      size: 35,
                      color: Color(0xff3F3D56),
                    ),
                    title: Text(
                      "FOLDER",
                      style: TextStyle(
                          color: Color(0xff2F2E41),
                          fontFamily: "Mulish",
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ),
                  value: 'folder',
                ),
              ];
            },
            onSelected: (value) {
              if (value == "note") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateNote()),
                );
              } else if (value == 'folder') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateFolder()),
                );
              }
              print('Selected: $value');
            },
          ),
        ),
      ),
    );
  }
}
