import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  final List<PhotoMemo> photoMemoList; //shared with me
  final User user;

  SharedWithScreen({required this.photoMemoList, required this.user});

  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controler con;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controler(this);
  }

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With ${widget.user.email}'),
      ),
      body: SingleChildScrollView(
        child: widget.photoMemoList.isEmpty
            ? Text('No PhotoMemos shared with me',style: Theme.of(context).textTheme.headline6,)
            : Column(
                children: [
                  for (var photoMemo in widget.photoMemoList)
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: WebImage(
                              url: photoMemo.photoURL,
                              context: context,
                              height: MediaQuery.of(context).size.height * 0.35,
                            ),
                          ),
                          Text(
                            photoMemo.title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(photoMemo.memo),
                          Text('Created by: ${photoMemo.createdBy}'),
                          Text('Created at: ${photoMemo.timestamp}'),
                          Text('Shared With: ${photoMemo.sharedWith}'),
                          Text('Image Labels: ${photoMemo.imageLabels}'),
                        ],
                      ),
                    )
                ],
              ),
      ),
    );
  }
}

class _Controler {
  late _SharedWithState state;
  _Controler(this.state);
}
