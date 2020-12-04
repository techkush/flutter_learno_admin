import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';
import 'package:uuid/uuid.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  TextEditingController topicController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  bool isLoading = false;
  String _topicId = '';
  String _question = '';
  String _answer = '';
  List<Map<String, dynamic>> answerList = [];

  bool _isThereAMessage = false;
  String _message;
  Color _messageColor = Colors.green;

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
                  'Quiz',
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
            //_imagePreview(),
            SizedBox(
              height: 20,
            ),
            //formFill(),
            SizedBox(
              height: 20,
            ),
            //TopicList()
          ],
        ),
      ),
    );
  }
}
