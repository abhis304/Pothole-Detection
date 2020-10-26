import 'dart:html';

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
    QuerySnapshot doc =
        await postRef.doc(widget.currentUser.id).collection('userPosts').get();

    // Cardd post = Cardd.fromDocument(doc);

    QuerySnapshot snapshot =
        await postRef.doc(widget.currentUser.id).collection('userPosts').get();

    if (doc.exists) {
      List<Cardd> posts =
          snapshot.docs.map((doc) => Cardd.fromDocument(doc)).toList();

      setState(() {
        this._posts = posts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getPost();
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Text('My Request'),
        centerTitle: true,
      ),
      body: _posts == null
          ? CircularProgressIndicator()
          : ListView(children: _posts),
    );
  }
}

class CardDemo extends StatelessWidget {
  final ImageData mediaUrl;
  final String des;
  final String location;

  const CardDemo({Key key, this.mediaUrl, this.des, this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: CachedNetworkImage(imageUrl: null),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Description :'),
                  Text('Location :'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Description :'),
                  Text('Location :'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
