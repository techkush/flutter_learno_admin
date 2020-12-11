import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<Map<String, dynamic>> answerList = [];
  final List<Map<String, dynamic>> questionList = [];

  bool _isThereAMessage = false;
  String _message;
  Color _messageColor = Colors.green;

  bool isCorrectAnswer = false;

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
            _questionPreview(),
            SizedBox(
              height: 20,
            ),
            formFill(),
            SizedBox(
              height: 20,
            ),
            _questionListPreview(),
            // Upload to database
            questionList.length > 0
                ? Container(
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
                            'Add Question',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                          onPressed: () async {
                            if(topicController.text.isNotEmpty){
                              setState(() {
                                isLoading = true;
                              });
                              FirebaseFirestore.instance
                                  .collection('app_settings')
                                  .doc('quiz')
                                  .collection('quizList')
                                  .doc(_topicId)
                                  .set({"questionList" : questionList}).then((value) {
                                errorMessageOpen(msg: 'Questions Added!', color: Colors.green);
                                setState(() {
                                  isLoading = false;
                                });
                                questionList.clear();
                              }).catchError((e) {
                                errorMessageOpen(msg: 'Something is wrong!', color: Colors.red);
                              });
                            }else{
                              errorMessageOpen(msg: 'Topic ID is required*', color: Colors.red);
                            }
                          },
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  addQuestion() {
    bool _haveCorrectAnswer = false;
    answerList.forEach((element) {
      if (element['correct']) {
        _haveCorrectAnswer = true;
      }
    });

    if (questionController.text.isNotEmpty) {
      if (_haveCorrectAnswer) {
        questionList.add({
          'question': questionController.text,
          'answers': List.of(answerList)
        });
        questionController.clear();
        answerController.clear();
        setState(() {
          isCorrectAnswer = false;
          _question = '';
        });
        answerList.clear();
      } else {
        errorMessageOpen(
            msg: 'There must be at least one correct answer',
            color: Colors.red);
      }
    } else {
      errorMessageOpen(msg: 'Question is required*', color: Colors.red);
    }
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
                      addQuestion();
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
              onTap: () {
                setState(() {
                  isCorrectAnswer = !isCorrectAnswer;
                });
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: isCorrectAnswer ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(
              width: 10,
            ),
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
                    border: OutlineInputBorder(), hintText: 'Answer'),
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
                      if (answerController.text.isNotEmpty) {
                        answerList.add({
                          "answer": answerController.text,
                          "correct": isCorrectAnswer
                        });
                        answerController.clear();
                        setState(() {
                          isCorrectAnswer = false;
                        });
                      } else {
                        errorMessageOpen(
                            msg: 'Answer is required*', color: Colors.red);
                      }
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

  Widget _questionPreview() {
    return _question == ''
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Question Preview', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 10,
              ),
              Text(_question, style: TextStyle(fontSize: 20)),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: answerList != null ? answerList.length : 0,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        trailing: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            answerList.removeAt(i);
                            setState(() {});
                          },
                        ),
                        title: Text(
                          '${i + 1}. ${answerList[i]['answer']}',
                          style: TextStyle(
                              color: answerList[i]['correct']
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ),
                    );
                  })
            ],
          );
  }

  Widget _questionListPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Quiz List of Module', style: TextStyle(fontSize: 20)),
        SizedBox(
          height: 10,
        ),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: questionList != null ? questionList.length : 0,
            itemBuilder: (context, i) {
              String correctAnswer = '';
              questionList[i]['answers'].forEach((element) {
                if (element['correct']) {
                  correctAnswer = element['answer'];
                }
              });
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  title: Text('${i + 1}. ${questionList[i]['question']}'),
                  subtitle: Text(correctAnswer, style: TextStyle(color: Colors.green),),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      questionList.removeAt(i);
                      setState(() {});
                    },
                  ),
                ),
              );
            })
      ],
    );
  }
}
