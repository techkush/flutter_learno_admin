import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/widgets/progress.dart';

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
  bool isCorrectAnswer = false;

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
            formFill(),
            SizedBox(
              height: 20,
            ),
            //TopicList()
          ],
        ),
      ),
    );
  }

  Widget formFill() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 300,
              child: TextFormField(
                controller: topicController,
                onChanged: (value) {
                  setState(() {
                    _topicId = value;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Topic Id'),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              width: 300,
              child: TextFormField(
                controller: questionController,
                onChanged: (value) {
                  setState(() {
                    _question = value;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Question'),
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
                      'Add Question',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: () async {

                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        // Answers
        Row(
          children: <Widget>[
            InkWell(
              onTap: (){
                setState(() {
                  isCorrectAnswer = !isCorrectAnswer;
                });
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: isCorrectAnswer ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            SizedBox(width: 10,),
            Container(
              width: 562,
              child: TextFormField(
                controller: answerController,
                onChanged: (value) {
                  setState(() {
                    _answer = value;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Question'),
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
                      'Add Answer',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: () {

                    },
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
