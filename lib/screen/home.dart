import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:pothole/Model/user.dart';
import 'package:pothole/screen/DrawerScreen.dart';
import 'package:pothole/screen/HomeScreen.dart';
import 'package:pothole/screen/create_account.dart';
import 'package:pothole/screen/intro_page.dart';
import 'package:pothole/screen/navigation_bloc.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final StorageReference storageRef = FirebaseStorage.instance.ref();
final postRef = FirebaseFirestore.instance.collection('posts');

final DateTime timestamp = DateTime.now();
User currentUser;
String currentUserDisplayName;
String photoUrlForProfile;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  bool showTextInternetNotConnected = false;

  @override
  void initState() {
    super.initState();

    connectivity = Connectivity();

    subscription = connectivity.onConnectivityChanged.listen((result) {
      _connectionStatus = result.toString();
      print('Connectivity Status' + _connectionStatus);

      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          showTextInternetNotConnected = false;
        });
        print('internet is on');

        pageController = PageController();

        // Detects when user signed in
        googleSignIn.onCurrentUserChanged.listen((account) {
          handleSignIn(account);
        }, onError: (error) {
          print('Error signing in : $error');
        });

        // Reauthenticate user when app is reopen

        googleSignIn.signInSilently(suppressErrors: false).then((account) {
          handleSignIn(account);
        }).catchError((error) {
          print('Error signing in : $error');
        });
      } else {
        setState(() {
          showTextInternetNotConnected = true;
        });
        print('Please Enable Your Internet Connection');
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    subscription.cancel();
    super.dispose();
  }

  createUserInFirestore() async {
    //steps :
    // 1) check if user exists in users collection in database (according to their id).

    final GoogleSignInAccount user = googleSignIn.currentUser;

    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist , then we want to take them to the create account page.

      final userName = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account , use it to make new user document in users collection.

      usersRef.doc(user.id).set({
        'id': user.id,
        'username': userName,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp,
      });

      // make the current user to their own follower (to include their post in timeline)
      // current user ni potani post ne timeline par display karva mate pela tene follower's ma add karva ma avse
    }

    currentUser = User.fromDocument(doc);

    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => IntroPage()));

    // photoUrlForProfile = currentUser.photoUrl;
    // currentUserDisplayName = currentUser.displayName;

    print(currentUser);
    print(currentUser.username);
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      // pela currentuser assigned thase then isAuth ni value set thay e mate await used karva ma avyu
      // nahitar currentuser set nai that e pela isAuth set thay jat.
      await createUserInFirestore();
      // photoUrlForProfile   = currentUser.photoUrl;
      print('User Signed in : $account');
      setState(() {
        isAuth = true;
      });
      // notification mate
      // configurePushNotification();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  // configurePushNotification() {
  //   final GoogleSignInAccount user = googleSignIn.currentUser;
  //   if (Platform.isIOS) getiOSPermission();

  //   _firebaseMessaging.getToken().then((token) {
  //     print("Firebase Messaging Token: $token\n");
  //     usersRef
  //         .document(user.id)
  //         .updateData({"androidNotificationToken": token});
  //   });

  //   _firebaseMessaging.configure(
  //     // onLaunch: (Map<String, dynamic> message) async {},
  //     // onResume: (Map<String, dynamic> message) async {},
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("on message: $message\n");
  //       final String recipientId = message['data']['recipient'];
  //       final String body = message['notification']['body'];
  //       if (recipientId == user.id) {
  //         print("Notification shown!");
  //         SnackBar snackbar = SnackBar(
  //             content: Text(
  //           body,
  //           overflow: TextOverflow.ellipsis,
  //         ));
  //         _scaffoldKey.currentState.showSnackBar(snackbar);
  //       }
  //       print("Notification NOT shown");
  //     },
  //   );
  // }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings registered: $settings");
    });
  }

  login() {
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    print('heloooo');
    // return RaisedButton(
    //   onPressed: logOut,
    //   child: Text('Logout'),
    // );

    return Scaffold(
      body: BlocProvider<NavigationBloc>(
        create: (context) => NavigationBloc(HomeScreen()),
        child: Stack(
          children: <Widget>[
            DrawerScreen(),
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, navigationState) {
                return navigationState as Widget;
              },
            ),
          ],
        ),
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomLeft,
        //     // List: [
        //     //   Colors.black,
        //     //   Colors.yellow,
        //     // ],
        //     // colors: [
        //     //   Theme.of(context).accentColor,
        //     //   Theme.of(context).primaryColor,
        //     // ],
        //   ),
        // ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Post Share',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 80.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            showTextInternetNotConnected
                ? Text(
                    'Please Enable Your Internet Connection',
                    style: TextStyle(color: Colors.white),
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
