import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DropDownSelector extends StatefulWidget {
  Function selectController;
  List<String> dropDownList;
  String title;
  Icon icon;

  DropDownSelector(
      {@required this.selectController,
        @required this.dropDownList,
        @required this.icon,
        @required this.title});

  @override
  _DropDownSelectorState createState() => _DropDownSelectorState();
}

class _DropDownSelectorState extends State<DropDownSelector> {
  String _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.icon,
            SizedBox(
              width: 10,
            ),
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  items: widget.dropDownList.map((view) {
                    return DropdownMenuItem(
                      child: Text(
                        view,
                      ),
                      value: view,
                    );
                  }).toList(),
                  value: _selectedValue,
                  onChanged: (dynamic newValue) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      _selectedValue = newValue;
                    });
                    widget.selectController(newValue);
                  },
                  hint:
                  Text(widget.title, style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
