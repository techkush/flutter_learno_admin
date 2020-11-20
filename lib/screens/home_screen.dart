import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.home, size: 20,),
              SizedBox(width: 10,),
              Text('Home Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
            ],
          ),
          SizedBox(height: 20,),
          Text("Structure for eLearning", style: TextStyle(fontSize: 17),),
          Image.asset('structure.png'),
          SizedBox(height: 25,),
        ],
      ),
    );
  }
}
