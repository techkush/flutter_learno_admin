import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase/firebase.dart' as fb;

class LessonScreen extends StatefulWidget {
  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  TextEditingController topicIdController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;
  Uint8List _uploadedImage;

  bool _isThereAMessage = false;
  String _message;
  Color _messageColor = Colors.green;

  final List<Map<String, dynamic>> lessonsList = [];

  submitDataToFirestore() {
    setState(() {
      isLoading = true;
    });
    List<Map<String, dynamic>> dataList = [];
    lessonsList.forEach((element) async {
      if (!(element['image'] == null)) {
        String path = await uploadToStorage(element['image']);
        dataList.add({'image': path, 'description': element['description']});
      } else {
        dataList.add(element);
      }
    });
    if (topicIdController.text.isNotEmpty) {
      uploadLessons(dataList);
    } else {
      errorMessageOpen(msg: 'Topic Id required!', color: Colors.green);
    }
  }

  // ignore: missing_return
  Future<String> uploadToStorage(Uint8List image) async {
    String randomImageName = Uuid().v4();
    final path = 'lessons/${topicIdController.text}/$randomImageName';
    await fb
        .storage()
        .refFromURL('gs://learno-c120b.appspot.com/')
        .child(path)
        .put(image, fb.UploadMetadata(contentType: 'image/jpeg'))
        .future
        .then((value) {
      fb
          .storage()
          .refFromURL('gs://learno-c120b.appspot.com/')
          .child(path)
          .getDownloadURL()
          .then((value) {
        return value.toString();
      });
    });
    topicIdController.clear();
  }

  uploadLessons(List<Map<String, dynamic>> listOfData) async {
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('lessons')
        .collection('lessonsList')
        .doc(topicIdController.text)
        .set({"lessonsList": listOfData}).then((value) {
      lessonsList.clear();
      errorMessageOpen(msg: 'Lessons List Added!', color: Colors.green);
    });
    setState(() {
      isLoading = false;
    });
  }

  void errorMessageOpen({String msg, Color color}) {
    setState(() {
      _message = msg;
      _messageColor = color;
      _isThereAMessage = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isThereAMessage = false;
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
          mainAxisSize: MainAxisSize.min,
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
                  'Lessons',
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
            SizedBox(
              height: 20,
            ),
            formFill(),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 715,
              child: TextFormField(
                controller: descriptionController,
                minLines: 2,
                maxLines: 5,
                maxLength: 150,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Description'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //_questionListPreview(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              height: 400,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lessonsList != null ? lessonsList.length : 0,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 300,
                      child: Card(
                        elevation: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Page ${index + 1}'),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    lessonsList.removeAt(index);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            lessonsList[index]['image'] == null
                                ? Container()
                                : Center(
                                    child: Container(
                                        height: 150,
                                        width: 250,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.memory(
                                            lessonsList[index]['image'],
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                  ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                    '${lessonsList[index]['description']}',
                                    maxLines: 20,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  addPageList() {
    if (!(_uploadedImage == null) || descriptionController.text.isNotEmpty) {
      lessonsList.add(
          {"image": _uploadedImage, "description": descriptionController.text});
      descriptionController.clear();
      setState(() {
        _uploadedImage = null;
      });
      errorMessageOpen(msg: 'Page Added!', color: Colors.green);
    } else {
      errorMessageOpen(
          msg: 'Must have at least one image or description.',
          color: Colors.red);
    }
  }

  Widget formFill() {
    return Row(
      children: <Widget>[
        Container(
          width: 300,
          child: TextFormField(
            controller: topicIdController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Topic Id'),
          ),
        ),
        SizedBox(
          width: 20,
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
                  'Add Page',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: () async {
                  addPageList();
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
        ),
        lessonsList.isNotEmpty
            ? Container(
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
                        'Upload to Database',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        submitDataToFirestore();
                      },
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
