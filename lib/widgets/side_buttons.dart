import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SideButton extends StatelessWidget {

  SideButton({@required this.handleFunction, @required this.name, @required this.icon, @required this.pageScreen});

  Function handleFunction;
  IconData icon;
  int pageScreen;
  String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      child: RaisedButton(
        onPressed: () {
          handleFunction(pageScreen);
        },
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              color: Colors.white,
              ),
          child: Container(
            constraints: BoxConstraints(minHeight: 60.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                SizedBox(width: 30,),
               Icon(icon),
                SizedBox(width: 10,),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: 13),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


}
