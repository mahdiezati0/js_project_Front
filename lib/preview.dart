import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'edit_note.dart';

class PreviewNote extends StatelessWidget {
  const PreviewNote({super.key});

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
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff00ADB5)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                      ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNote(
                          memoId: '1',
                          initialTitle: 'Initial Title',
                          initialContent: 'Initial Content',
                        ),
                      ),
                    );
                  },


                  child: Text(
                    "Edit Note",
                    style: TextStyle(
                        color: Color(0xff2F2E41),
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        fontSize: 19),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      // put the title of note in this widget?
                      child: Text(
                        "Note Title",
                        style: TextStyle(
                            color: Color(0xff2F2E41),
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 32),
                      ),
                    ),
                    height: 40,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  PreferredSize(
                    preferredSize: Size.fromHeight(10.0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Container(
                        color: Color(0xff3F3D56),
                        height: 3.3,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      //put the note inside of this widget?
                      child: Text(
                        "note details \n bruh \n bruh\na",
                        style: TextStyle(
                            color: Color(0xff2F2E41),
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              )),
        ),
      ),
    );
  }
}
