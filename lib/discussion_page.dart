import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Flutter_Chat_Application/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
final reference = FirebaseDatabase.instance.reference().child('Blogs');

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) user = await googleSignIn.signInSilently();
  if (user == null) {
    user = await googleSignIn.signIn();
    analytics.logLogin();
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: credentials.accessToken,
      idToken: credentials.idToken,
    );
    await auth.signInWithCredential(credential);
  }
}

class PostBlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext context) => new HomePage(),
      },
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Add Question'),
          ),
          body: new _PostPage()),
    );
  }
}

class _PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => new _PostPageState();
}

class _PostPageState extends State<_PostPage> {
  final TextEditingController _title = new TextEditingController();
  final TextEditingController _desc = new TextEditingController();
  bool _isTitle = false;
  bool _isDesc = false;
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        reverse: true,
        child: new Container(
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: _isLoading ? new CircularProgressIndicator() : null,
              ),
              new Padding(
                padding: const EdgeInsets.all(20.0),
                child: new TextField(
                  controller: _title,
                  style: new TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                  onChanged: (String text) {
                    setState(() {
                      _isTitle = text.length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                    hintText: "Question",
                    border: new UnderlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          style: BorderStyle.solid,
                          width: 5.0),
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(20.0),
                child: new TextField(
                  controller: _desc,
                  style: new TextStyle(color: Colors.black, fontSize: 18.0),
                  onChanged: (String text) {
                    setState(() {
                      _isDesc = text.length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                    hintText: "Question Description",
                    border: new UnderlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          style: BorderStyle.solid,
                          width: 5.0),
                    ),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new RaisedButton(
                  padding: const EdgeInsets.only(
                      left: 45.0, right: 45.0, top: 15.0, bottom: 15.0),
                  color: Colors.blueAccent,
                  elevation: 2.0,
                  child: new Text(
                    "Post",
                    style: new TextStyle(color: Colors.white),
                  ),
                  onPressed: _isTitle && _isDesc && !_isLoading
                      ? () => _handleSubmitted(_title.text, _desc.text)
                      : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _handleSubmitted(String title, String desc) async {
    setState(() {
      _isLoading = true;
    });
    await _ensureLoggedIn();

//    StorageReference ref = FirebaseStorage.instance.ref().child("Blog_Images/" +
//        new DateTime.now().millisecondsSinceEpoch.toString()); //new
    _addBlog(title, desc);
  }

  void _addBlog(String title, String description) {
//    print(googleSignIn.currentUser.displayName);
//    print(googleSignIn.currentUser.id);
//    print(title);
//    print(imageUrl);
//    print(description);
    reference.push().set({
      'Title': title,
      'DESCRIPTION': description,
      'uid': googleSignIn.currentUser.id,
      'username': googleSignIn.currentUser.displayName
    });
//    Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (Builder)))
//    Navigator.of(context).pushAndRemoveUntil(
//        new MaterialPageRoute(
//            builder: (BuildContext context) => new HomePage()),
//        (Route route) => route == null);
//    print("success");
    analytics.logEvent(name: 'post_blog');
    setState(() {
      _isLoading = false;
      _title.clear();
      _desc.clear();
      _isTitle = false;
      _isDesc = false;
    });
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text("Posted Successfully!"),
    ));
  }
}