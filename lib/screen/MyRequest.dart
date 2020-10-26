import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pothole/Model/user.dart';
import 'package:pothole/screen/home.dart';

class MyRequest extends StatefulWidget {
  final User currentUser;

  const MyRequest({Key key, this.currentUser}) : super(key: key);

  @override
  _MyRequestState createState() => _MyRequestState();
}

class _MyRequestState extends State<MyRequest> {
  List<Cardd> _posts;
  getPost() async {
    print('hii');
    QuerySnapshot docuu =
        await postRef.doc(widget.currentUser.id).collection('userPosts').get();

    final List<DocumentSnapshot> documents = docuu.docs;

    print(documents);

    QuerySnapshot snapshot =
        await postRef.doc(widget.currentUser.id).collection('userPosts').get();

    List<Cardd> posts =
        snapshot.docs.map((docu) => Cardd.fromDocument(docu)).toList();
    setState(() {
      this._posts = posts;
    });

    if (documents != null) {
      documents.forEach((data) async {
        print('hii11');
        print(data);

        DocumentSnapshot docc = await postRef
            .doc(widget.currentUser.id)
            .collection('userPosts')
            .doc(data.id)
            .get();

        if (docc.exists) {
          print(docc["location"]);

          // List<Cardd> posts =
          //     snapshot.documents.map((doc) => Cardd.fromDocument(doc)).toList();

          // setState(() {
          //   this._posts = posts;
          // });
        }
      });
    } else {
      print('2222222');
    }

    // DocumentReference documentReference =
    //     postRef.doc(widget.currentUser.id).collection('userPosts').doc();

    // Cardd post = Cardd.fromDocument(doc);

    // QuerySnapshot snapshot =
    //     await postRef.doc(widget.currentUser.id).collection('userPosts').get();
  }

  @override
  void initState() {
    super.initState();
    getPost();
  }

  @override
  Widget build(BuildContext context) {
    // getPost();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          'My Request',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: _posts == null
            ? CircularProgressIndicator()
            : ListView(children: _posts),
      ),
    );
  }
}

// class CardDemo extends StatelessWidget {
//   final String mediaUrl;
//   final String des;
//   final String location;

//   const CardDemo({Key key, this.mediaUrl, this.des, this.location})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height * 0.25,
//         child: Row(
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width * 0.4,
//               child: CachedNetworkImage(imageUrl: null),
//             ),
//             Container(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Description :'),
//                   Text('Location :'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class Cardd extends StatefulWidget {
  final String mediaUrl;
  final String des;
  final String location;

  const Cardd({Key key, this.mediaUrl, this.des, this.location})
      : super(key: key);

  factory Cardd.fromDocument(DocumentSnapshot doc) {
    return Cardd(
      location: doc['location'],
      des: doc['description'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  @override
  _CarddState createState() => _CarddState(
      des: this.des, location: this.location, mediaUrl: this.mediaUrl);
}

class _CarddState extends State<Cardd> {
  final String mediaUrl;
  final String des;
  final String location;

  _CarddState({this.mediaUrl, this.des, this.location});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 10,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: CachedNetworkImage(
                  imageUrl: mediaUrl,
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Description : $des',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Location : $location',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
