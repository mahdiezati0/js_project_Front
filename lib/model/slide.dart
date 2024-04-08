import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
      imageUrl: 'assets/images/slide1.png',
      title: "Note Organization and Navigation",
      description:
          "1. Categorize Notes\n2. Search Notes\n3. Sort Notes\n4. Navigate Between Notes"),
  Slide(
    imageUrl: 'assets/images/slide2.png',
    title: "Note Sharing        and Collaboration",
    description:
        "1. Share Note\n2. Collaborate on Note\n3. View Note History\n4. Add Attachments",
  ),
  Slide(
      imageUrl: 'assets/images/slide3.png',
      title: "Customization and Settings",
      description:
          "1. Change Note Color\n2. Set Reminders\n3. Dark Mode\n4. Backup and Sync"),
];
