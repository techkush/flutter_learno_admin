import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno_admin/screens/home_screen.dart';
import 'package:flutter_learno_admin/screens/lesson_screen.dart';
import 'package:flutter_learno_admin/screens/level_screen.dart';
import 'package:flutter_learno_admin/screens/module_screen.dart';
import 'package:flutter_learno_admin/screens/quiz_screen.dart';
import 'package:flutter_learno_admin/screens/settings_screen.dart';
import 'package:flutter_learno_admin/screens/subject_screen.dart';
import 'package:flutter_learno_admin/screens/topic_screen.dart';
import 'package:flutter_learno_admin/widgets/side_buttons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learno Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          //primarySwatch: Colors.blue,
          primaryColorDark: Color(0xff615DFA),
          primaryColorLight: Color(0xff23D2E2),
          fontFamily: 'Montserrat'
          //accentColor: Color(0xff05D2DD),
          ),
      home: MyHomePage(title: 'Learno Admin Panel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageIndex = 0;

  setPageIndex(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  // ignore: missing_return
  Widget screen(context) {
    if (_pageIndex == 0) return HomeScreen();
    if (_pageIndex == 1) return LevelScreen();
    if (_pageIndex == 2) return SubjectScreen();
    if (_pageIndex == 3) return ModuleScreen();
    if (_pageIndex == 4) return TopicScreen();
    if (_pageIndex == 5) return LessonScreen();
    if (_pageIndex == 6) return QuizScreen();
    if (_pageIndex == 7) return SettingsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Icon(Icons.account_balance),
        backgroundColor: Color(0xff615DFA),
      ),
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Container(
              width: 200,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Home",
                    icon: Icons.home,
                    pageScreen: 0,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Level",
                    icon: Icons.album_rounded,
                    pageScreen: 1,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Subject",
                    icon: Icons.subject,
                    pageScreen: 2,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Module",
                    icon: Icons.view_module_outlined,
                    pageScreen: 3,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Topics",
                    icon: Icons.topic,
                    pageScreen: 4,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Lessons",
                    icon: Icons.book,
                    pageScreen: 5,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Quiz",
                    icon: Icons.question_answer,
                    pageScreen: 6,
                  ),
                  SideButton(
                    handleFunction: setPageIndex,
                    name: "Settings",
                    icon: Icons.settings,
                    pageScreen: 7,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 230,
                decoration: BoxDecoration(
                  color: Colors.red
                ),
                child: screen(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
