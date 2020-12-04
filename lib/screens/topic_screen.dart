import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/widgets/module_screen_list.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';
import 'package:flutter_learno_admin/widgets/topic_screen_list.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase/firebase.dart' as fb;

class TopicScreen extends StatefulWidget {
  @override
  _TopicScreenState createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  TextEditingController topicController = TextEditingController();
  TextEditingController moduleController = TextEditingController();
  bool isLoading = false;
  String _moduleId = '';
  String _topic = '';
  String topicId = Uuid().v4();
  Uint8List _uploadedImage;
  bool _isThereAMessage = false;
  String _message;
  Color _messageColor = Colors.green;

  _checkFile() {
    if (_uploadedImage == null || _topic.isEmpty || _moduleId.isEmpty) {
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
    final path = 'topic/$topicId';
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
    topicController.clear();
    moduleController.clear();
    setState(() {
      _uploadedImage = null;
      isLoading = false;
    });
  }

  uploadToSubjectData(String mediaUrl) async {
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('topics')
        .collection('topicsList')
        .doc(topicId)
        .set({
      'moduleId': _moduleId,
      'mediaUrl': mediaUrl,
      'id': topicId,
      'name': _topic,
      'quiz': null,
      'lessons': null
    }).then((value) {
      setState(() {
        _message = 'Added module details!';
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
                  Icons.accessibility,
                  size: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Topics',
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
            TopicList()
          ],
        ),
      ),
    );
  }

  Widget formFill() {
    return Row(
      children: <Widget>[
        Container(
          width: 300,
          child: TextFormField(
            controller: topicController,
            onChanged: (value) {
              setState(() {
                _moduleId = value;
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Module Id'),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Container(
          width: 300,
          child: TextFormField(
            controller: moduleController,
            onChanged: (value) {
              setState(() {
                _topic = value;
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Topic name'),
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
                      '$_topic',
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
}
