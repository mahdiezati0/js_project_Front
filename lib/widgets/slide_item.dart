import 'package:flutter/material.dart';
import 'package:note_app/model/slide.dart';

class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            child: Image.asset(slideList[index].imageUrl),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              slideList[index].title,
              style: TextStyle(
                  color: Color(
                    0xff222831,
                  ),
                  fontFamily: 'roboto',
                  fontSize: 38),
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  slideList[index].description,
                  style: TextStyle(
                      color: Color(0xff393E46),
                      fontFamily: 'roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
