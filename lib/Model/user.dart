import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String photoUrl;
  final String email;
  final String displayName;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.get('id'),
      email: doc.get('email'),
      username: doc.get('username'),
      photoUrl: doc.get('photoUrl'),
      displayName: doc.get('displayName'),
    );
  }
}
