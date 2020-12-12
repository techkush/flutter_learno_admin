import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/widgets/module_screen_list.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase/firebase.dart' as fb;

class ModuleScreen extends StatefulWidget {
  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  TextEditingController subjectIdController = TextEditingController();
  TextEditingController moduleController = TextEditingController();
  bool isLoading = false;
  String _subjectId = '';
  String _module = '';
  Uint8List _uploadedImage;
  bool _isThereAMessage = false;
  String _message;
  Color _messageColor = Colors.green;

  _checkFile() {
    if (_uploadedImage == null || _module.isEmpty || _subjectId.isEmpty) {
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
    String imageId = Uuid().v4();
    final path = 'module/$imageId';
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
        uploadToSubjectData(value.toString(), imageId);
      });
    });
  }

  uploadToSubjectData(String mediaUrl, String imageId) async {
    String moduleId = Uuid().v4();
    await FirebaseFirestore.instance
        .collection('app_settings')
        .doc('modules')
        .collection('moduleList')
        .doc(moduleId)
        .set({
      'subjectId': _subjectId,
      'mediaUrl': mediaUrl,
      'id': moduleId,
      'imageId': imageId,
      'name': _module
    }).then((value) {
      setState(() {
        _message = 'Added module details!';
        _messageColor = Colors.green;
        _isThereAMessage = true;
        _uploadedImage = null;
        isLoading = false;
        _module = '';
      });
      subjectIdController.clear();
      moduleController.clear();
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
                  'Modules',
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
            ModuleList()
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
            controller: subjectIdController,
            onChanged: (value) {
              setState(() {
                _subjectId = value;
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Subject Id'),
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
                _module = value;
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Module name'),
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
                      '$_module',
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
