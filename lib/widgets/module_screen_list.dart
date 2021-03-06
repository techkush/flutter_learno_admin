import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;

class ModuleList extends StatelessWidget {
  Widget _levelListWidget(BuildContext context) {
    Stream<QuerySnapshot> courseDocStream = FirebaseFirestore.instance
        .collection('app_settings')
        .doc('modules')
        .collection('moduleList')
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
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Image(
                              image: NetworkImage(courseDocument[i]['mediaUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: InkWell(child: Text('Module : ${courseDocument[i]['name']}'), onTap: (){
                            FlutterClipboard.copy(courseDocument[i]['id']).then(( value ) => print('copied'));
                          },),
                          subtitle: Text('Subject Id : ${courseDocument[i]['subjectId']}'),
                          trailing: InkWell(
                            child: Text('❌'),
                            onTap: () async{
                              await fb
                                  .storage()
                                  .refFromURL('gs://learno-c120b.appspot.com/')
                                  .child('module/${courseDocument[i]['imageId']}')
                                  .delete()
                                  .then((value) {
                                FirebaseFirestore.instance
                                    .collection('app_settings')
                                    .doc('modules')
                                    .collection('moduleList')
                                    .doc(courseDocument[i]['id'])
                                    .delete();
                              });
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
