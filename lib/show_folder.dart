import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_app/create_note.dart';
import 'package:note_app/token_manager.dart';
import 'package:note_app/edit_note.dart';
import 'package:note_app/main_page.dart';
import 'package:note_app/note_folder.dart';

class ShowFolder extends StatefulWidget {
  final String title;
  final String categoryId;

  const ShowFolder({Key? key, required this.title, required this.categoryId})
      : super(key: key);

  @override
  _ShowFolderState createState() => _ShowFolderState();
}

class _ShowFolderState extends State<ShowFolder> {
  List<Map<String, dynamic>> notes = [];
  bool isDeletingMode = false;
  Set<int> selectedNotes = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String apiUrl =
        'https://notivous.liara.run/Memo/GetByCategory/${widget.categoryId}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${TokenManager.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<Map<String, dynamic>> fetchedNotes =
        List<Map<String, dynamic>>.from(responseData['value']);
        setState(() {
          notes = fetchedNotes;
        });
      } else {
        print('Error fetching notes: ${response.statusCode}');
        _showSnackBar(
            'Error fetching notes: ${response.statusCode}', Colors.red);
      }
    } catch (error) {
      print('Error fetching notes: $error');
      _showSnackBar('Error fetching notes. Please try again.', Colors.red);
    }
  }

  Future<void> deleteSelectedNotes() async {
    final String apiUrl = 'https://notivous.liara.run/Memo/Delete/';

    try {
      final List<int> selectedIndices = selectedNotes.toList();
      await Future.wait(selectedIndices.map((int index) async {
        final response = await http.delete(
          Uri.parse('$apiUrl${notes[index]['id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${TokenManager.getToken()}',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            notes.removeAt(index);
            _showSnackBar('Note Deleted Successfully', Colors.green);
          });
        } else {
          print('Error deleting note: ${response.statusCode}');
          _showSnackBar(
              'Error deleting note: ${response.statusCode}', Colors.red);
        }
      }));
      setState(() {
        selectedNotes.clear();
      });

      await fetchData();
    } catch (error) {
      print('Error deleting notes: $error');
      _showSnackBar('Error deleting notes. Please try again.', Colors.red);
    }
    await fetchData();
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
        title: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, right: 10),
            child: Text(
              widget.title, // استفاده از عنوان پوشه
              style: TextStyle(
                color: Color(0xff2F2E41),
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: Icon(
              isDeletingMode ? Icons.close : Icons.arrow_back_ios,
              color: Color(0xff2F2E41),
            ),
            iconSize: 50,
            onPressed: () {
              setState(() {
                if (isDeletingMode) {
                  isDeletingMode = false;
                  selectedNotes.clear();
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()), // تغییر به صفحه اصلی
                  );
                }
              });
            },
          ),
        ),
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
      body: SafeArea(
        child: RefreshIndicator(
          color: Color(0xff00ADB5),
          onRefresh: fetchData,
          child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
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
              }),
        ),
      ),
      floatingActionButton: isDeletingMode
          ? FloatingActionButton(
        onPressed: deleteSelectedNotes,
        child: Icon(
          Icons.delete,
          size: 30,
        ),
        backgroundColor: Colors.red,
      )
          : FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteFolder(categoryId: widget.categoryId)),
        ),
        child: Icon(
          Icons.add,
          size: 30,
        ),
        backgroundColor: Color(0xff00ADB5),
      ),
    );
  }
}
