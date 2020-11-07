import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LevelScreen extends StatefulWidget {
  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {

  String message = '';
  Color messageColor = Colors.green;
  bool isThereAMessage = false;
  TextEditingController levelController = TextEditingController();
  List<String> _levelList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void errorMessageOpen({String msg, Color color}) {
    setState(() {
      message = msg;
      messageColor = color;
      isThereAMessage = true;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isThereAMessage = false;
      });
    });
  }

  Future<void> deleteData(int index) async {
    await getLevelList();
    _levelList.removeAt(index);
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('levels')
        .set({"levels": _levelList}).then((value) {
      errorMessageOpen(msg: 'Level name deleted!', color: Colors.red);
    }).catchError((e) {
      errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
    });
    _levelList.clear();
  }

  Future<void> submit() async {
    await getLevelList();
    if (_levelList == null) {
      FirebaseFirestore.instance.collection('app_settings').doc('levels').set({
        "levels": [levelController.text]
      }).then((value) {
        errorMessageOpen(msg: 'Level name added!', color: Colors.green);
      }).catchError((e) {
        errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
      });
    } else {
      _levelList.add(levelController.text);
      if (levelController != null) {
        FirebaseFirestore.instance
            .collection('app_settings')
            .doc('levels')
            .set({"levels": _levelList}).then((value) {
          errorMessageOpen(msg: 'Level name added!', color: Colors.green);
        }).catchError((e) {
          errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
        });
      } else {
        errorMessageOpen(msg: 'TextField is empty!', color: Colors.red);
      }
    }
    levelController.clear();
    _levelList.clear();
  }

  Future<void> getLevelList() async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('app_settings')
        .doc('levels')
        .get();
    if (doc.exists) {
      Levels _levels = Levels.fromDocument(doc);
      for (final e in _levels.levelList) {
        _levelList.add(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.ac_unit,
                  size: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Level Screen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // Error Message
            isThereAMessage
                ? Container(
                    width: MediaQuery.of(context).size.width - 260,
                    height: 40,
                    decoration: BoxDecoration(
                      color: messageColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                : Container(),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: levelController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Level name'),
                  ),
                ),
                Container(
                  width: 200,
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30)),
                      width: MediaQuery.of(context).size.width - 30,
                      child: RaisedButton(
                        child: Text(
                          'Add List',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          submit();
                        },
                      ),
                    ),
                  ),
                ),

                // Level List
              ],
            ),
            Divider(
              height: 1,
            ),
            Container(width: 490,child: _levelListWidget(context))
          ],
        ),
      ),
    );
  }

  Widget _levelListWidget(BuildContext context) {
    Stream<DocumentSnapshot> courseDocStream = FirebaseFirestore.instance
        .collection('app_settings')
        .doc('levels')
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
        stream: courseDocStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            var courseDocument = snapshot.data.data();
            var sections = courseDocument['levels'];
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sections != null ? sections.length : 0,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    height: 50,
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Text('🔯   ${sections[i]}'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              InkWell(child: Text('❌'), onTap: (){
                                deleteData(i);
                              },),
                              SizedBox(width: 20,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Container(child: Text('No Values!'),);
          }
        });
  }
}

class Levels {
  List levelList;

  Levels({this.levelList});

  factory Levels.fromDocument(DocumentSnapshot doc) {
    return Levels(levelList: doc['levels']);
  }
}
