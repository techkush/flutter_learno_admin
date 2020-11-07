import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LevelsListBuilder extends StatelessWidget {
  Stream<DocumentSnapshot> courseDocStream = FirebaseFirestore.instance
      .collection('app_settings')
      .doc('levels')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: courseDocStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            var courseDocument = snapshot.data.data();
            var sections = courseDocument['levels'];
            print(sections[0]);
            return ListView.builder(
              itemCount: sections != null ? sections.length : 0,
              itemBuilder: (context, i) {
                return ListTile(title: Container(child: Text(sections[i])));
              },
            );
          } else {
            return Container();
          }
        });
  }
}
