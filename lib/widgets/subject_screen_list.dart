import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectList extends StatelessWidget {
  Widget _levelListWidget(BuildContext context) {
    Stream<QuerySnapshot> courseDocStream = FirebaseFirestore.instance
        .collection('app_settings')
        .doc('subjects')
        .collection('subjectList')
        .snapshots();

    // courseDocStream.forEach((field) {
    //   print(field.size);
    //   field.docs.asMap().forEach((index, data) {
    //     print(field.docs[index]["level"]);
    //   });
    // });
    //return Container();

    return StreamBuilder<QuerySnapshot>(
        stream: courseDocStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            var courseDocument = snapshot.data.docs;
            //var sections = courseDocument['levels'];
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: courseDocument != null ? courseDocument.length : 0,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    height: 100,
                    child: Card(
                        child: ListTile(
                      leading: Container(
                        height: 300,
                        width: 250,
                        child: Image(
                          image: NetworkImage(courseDocument[i]['mediaUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text('Subject : ${courseDocument[i]['name']}'),
                      subtitle: Text('Level : ${courseDocument[i]['level']}'),
                      trailing: InkWell(
                        child: Text('❌'),
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('app_settings')
                              .doc('subjects')
                              .collection('subjectList')
                              .doc(courseDocument[i]['id'])
                              .delete();
                        },
                      ),
                    )),
                  ),
                );
              },
            );
          } else {
            return Container(
              child: Text('No Values!'),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return _levelListWidget(context);
  }
}
