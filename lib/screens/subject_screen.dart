// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/errors/common_errors.dart';
import 'package:flutter_learno_admin/screens/level_screen.dart';
import 'package:flutter_learno_admin/widgets/drop_down.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase/firebase.dart' as fb;

class SubjectScreen extends StatefulWidget {
  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  TextEditingController subjectController = TextEditingController();
  List<String> _levelList = [];
  bool isLoading = false;
  String _level = '';
  String _subject = '';
  String subjectId = Uuid().v4();
  Uint8List _uploadedImage;
  bool _isThereAMessage = false;
  String _message;
  Color _messageColor = Colors.green;

  _checkFile() {
    if (_uploadedImage == null || _level.isEmpty || _subject.isEmpty) {
      setState(() {
        _message = 'Please fill the all details!';
        _messageColor = Colors.red;
        _isThereAMessage = true;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _isThereAMessage = false;
        });
      });
    } else {
      uploadToStorage();
    }
  }

  uploadToStorage() async {
    setState(() {
      isLoading = true;
    });
    final path = 'subject/$subjectId';
    await fb
        .storage()
        .refFromURL('gs://learno-c120b.appspot.com/')
        .child(path)
        .put(_uploadedImage, fb.UploadMetadata(contentType: 'image/jpeg'))
        .future
        .then((value) {
      fb
          .storage()
          .refFromURL('gs://learno-c120b.appspot.com/')
          .child(path)
          .getDownloadURL()
          .then((value) {
        uploadToSubjectData(value.toString());
      });
    });
    subjectController.clear();
    setState(() {
      _uploadedImage = null;
      isLoading = false;
    });
  }

  uploadToSubjectData(String mediaUrl) async {
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('subjects')
        .collection('subjectList')
        .doc(subjectId)
        .set({
      'name': _subject,
      'level': _level,
      'mediaUrl': mediaUrl,
      'id': subjectId
    }).then((value) {
      setState(() {
        _message = 'Added subject details!';
        _messageColor = Colors.green;
        _isThereAMessage = true;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _isThereAMessage = false;
        });
      });
    });
  }

  _startFilePicker() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        FileReader reader = FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            _uploadedImage = reader.result;
          });
        });

        reader.onError.listen((fileEvent) {
          print('error');
        });
        reader.readAsArrayBuffer(file);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLevelList();
  }

  getLevelList() async {
    setState(() {
      isLoading = true;
    });
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('app_settings')
        .doc('levels')
        .get();
    if (doc.exists) {
      _levelList.clear();
      Levels _levels = Levels.fromDocument(doc);
      for (final e in _levels.levelList) {
        _levelList.add(e);
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
                  Icons.subject,
                  size: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Subjects',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            _isThereAMessage
                ? Container(
                    width: MediaQuery.of(context).size.width - 250,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _messageColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        _message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                : Container(),
            _imagePreview(),
            SizedBox(
              height: 20,
            ),
            formFill(),
            SizedBox(
              height: 20,
            ),
            _showSubjectList(),
          ],
        ),
      ),
    );
  }

  Widget formFill() {
    return Row(
      children: <Widget>[
        DropDownSelector(
            selectController: (level) {
              setState(() {
                _level = level;
              });
            },
            dropDownList: _levelList == null ? [' '] : _levelList,
            icon: Icon(Icons.ac_unit),
            title: 'Select Level'),
        SizedBox(
          width: 20,
        ),
        Container(
          width: 300,
          child: TextFormField(
            controller: subjectController,
            onChanged: (value) {
              setState(() {
                _subject = value;
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Subject name'),
          ),
        ),
        Container(
          width: 200,
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 40,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                child: Text(
                  'Add List',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: () async {
                  _checkFile();
                },
              ),
            ),
          ),
        ),
        Container(
          width: 200,
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 40,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                child: Text(
                  'Upload Image',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: () {
                  _startFilePicker();
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _imagePreview() {
    return _uploadedImage == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Preview', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 10,
              ),
              Stack(
                children: <Widget>[
                  Container(
                      height: 150,
                      width: 400,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.memory(
                          _uploadedImage,
                          fit: BoxFit.cover,
                        ),
                      )),
                  Container(
                    height: 150,
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            '$_level | $_subject',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
  }

  Widget _showSubjectList() {
    return Container();
  }
}
