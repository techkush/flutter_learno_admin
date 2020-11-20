import 'package:flutter/material.dart';

class ModuleScreen extends StatefulWidget {
  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  String path = 'https://firebasestorage.googleapis.com/v0/b/learno-c120b.appspot.com/o/subject%2F1bbbc66f-ac4b-43d5-85d5-831c9c1f6eee?alt=media&token=04e8641b-85fc-4a70-83a6-f515442e9dc4';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(path),
      ),
    );
  }
}
