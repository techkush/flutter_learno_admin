import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String message = '';
  Color messageColor = Colors.green;
  bool isThereAMessage = false;
  TextEditingController schoolController = TextEditingController();
  List<String> _schoolsList = [];
  bool isLoading = false;

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
    setState(() {
      isLoading = true;
    });
    await getLevelList();
    _schoolsList.removeAt(index);
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('schools')
        .set({"schools": _schoolsList}).then((value) {
      errorMessageOpen(msg: 'School name deleted!', color: Colors.red);
    }).catchError((e) {
      errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
    });
    _schoolsList.clear();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> submit() async {
    setState(() {
      isLoading = true;
    });
    await getLevelList();
    if (_schoolsList == null) {
      FirebaseFirestore.instance.collection('app_settings').doc('schools').set({
        "schools": [schoolController.text]
      }).then((value) {
        errorMessageOpen(msg: 'School name added!', color: Colors.green);
      }).catchError((e) {
        errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
      });
    } else {
      _schoolsList.add(schoolController.text);
      if (schoolController != null) {
        FirebaseFirestore.instance
            .collection('app_settings')
            .doc('schools')
            .set({"schools": _schoolsList}).then((value) {
          errorMessageOpen(msg: 'School name added!', color: Colors.green);
        }).catchError((e) {
          errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
        });
      } else {
        errorMessageOpen(msg: 'TextField is empty!', color: Colors.red);
      }
    }
    schoolController.clear();
    _schoolsList.clear();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getLevelList() async {
    setState(() {
      isLoading = true;
    });
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('app_settings')
        .doc('schools')
        .get();
    if (doc.exists) {
      Schools _levels = Schools.fromDocument(doc);
      for (final e in _levels.levelList) {
        _schoolsList.add(e);
      }
    }
    setState(() {
      isLoading = false;
    });
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
            isLoading ? linearProgress() : Container(),
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
                  'Settings - Add School List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: schoolController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'School name'),
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
                          if (schoolController.text.length < 1) {
                            errorMessageOpen(
                                msg: 'School field is empty.',
                                color: Colors.red);
                          } else {
                            submit();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                isThereAMessage
                    ? Container(
                    width: 300,
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
                // Level List
              ],
            ),
            Divider(
              height: 1,
            ),
            Container(width: 490, child: _levelListWidget(context))
          ],
        ),
      ),
    );
  }

  Widget _levelListWidget(BuildContext context) {
    Stream<DocumentSnapshot> courseDocStream = FirebaseFirestore.instance
        .collection('app_settings')
        .doc('schools')
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
        stream: courseDocStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            var courseDocument = snapshot.data.data();
            var sections = courseDocument['schools'];
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
                              SizedBox(
                                width: 20,
                              ),
                              Text('🔯   ${sections[i]}'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              InkWell(
                                child: Text('❌'),
                                onTap: () {
                                  deleteData(i);
                                },
                              ),
                              SizedBox(
                                width: 20,
                              ),
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
            return Container(
              child: Text('No Values!'),
            );
          }
        });
  }
}

class Schools {
  List levelList;

  Schools({this.levelList});

  factory Schools.fromDocument(DocumentSnapshot doc) {
    return Schools(levelList: doc['schools']);
  }
}
