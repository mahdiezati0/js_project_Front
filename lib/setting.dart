import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0E0E0),
      appBar: AppBar(
        backgroundColor: Color(0xffE0E0E0),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: Colors.grey,
              thickness: 4,
              height: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'BackUp and Restore',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: "Mulish",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00ACB5),
                    minimumSize: Size(100 * MediaQuery.of(context).size.width, 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.backup, size: 24, color: Colors.black),
                  label: Text('BackUp', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00ACB5),
                    minimumSize: Size(100 * MediaQuery.of(context).size.width, 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.restore, size: 24, color: Colors.black),
                  label: Text('Restore', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 15),
                Divider(color: Colors.grey, thickness: 1),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0), // اضافه کردن حاشیه
                  child: Text(
                    'Account Setting',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: "Mulish",
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Log Out?",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Mulish",
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to log out?",
                            style: TextStyle(
                              color: Color(0xFF444444),
                              fontFamily: "Mulish",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    ).then((logout) {
                      if (logout ?? false) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00ACB5),
                    minimumSize: Size(100 * MediaQuery.of(context).size.width, 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.logout, size: 24, color: Colors.black),
                  label: Text('Log Out', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
