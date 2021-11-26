import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
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
  late List<TextEditingController> commentController;
  late _Controller con;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
    commentController = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    commentController.clear();
    super.dispose();
  }

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With ${widget.user.email}'),
      ),
      // body: SingleChildScrollView(
      //   child: widget.photoMemoList.isEmpty
      //       ? Text(
      //           'No PhotoMemos shared with me',
      //           style: Theme.of(context).textTheme.headline6,
      //         )
      //       : Column(
      //           children: [
      //             for (var photoMemo in widget.photoMemoList)
      //               Card(
      //                 elevation: 8.0,
      //                 shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(16.0)),
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Center(
      //                       child: WebImage(
      //                         url: photoMemo.photoURL,
      //                         context: context,
      //                         height: MediaQuery.of(context).size.height * 0.35,
      //                       ),
      //                     ),
      //                     Text(
      //                       photoMemo.title,
      //                       style: Theme.of(context).textTheme.headline6,
      //                     ),
      //                     Text(photoMemo.memo),
      //                     Text('Created by : ${photoMemo.createdBy}'),
      //                     Text('Created at : ${photoMemo.timestamp}'),
      //                     Text('Shared With : ${photoMemo.sharedWith}'),
      //                     Text('Image Labels : ${photoMemo.imageLabels}'),
      //                     SizedBox(height: 10),
      //                     Row(
      //                       children: [
      //                         Expanded(
      //                           child: TextFormField(
      //                             maxLines: 1,
      //                             controller: commentController,
      //                             decoration: InputDecoration(
      //                               hintText: 'Comment here ...',
      //                               focusedBorder: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(15),
      //                               ),
      //                               enabledBorder: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(15),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         IconButton(
      //                           onPressed: () async {
      //                             con.addComment();
      //                           },
      //                           icon: Icon(Icons.send),
      //                         ),
      //                       ],
      //                     ),
      //                   ],
      //                 ),
      //               )
      //           ],
      //         ),
      // ),
      body: Container(
        child: widget.photoMemoList.isEmpty
            ? Text('No PhotoMemos shared with me')
            : ListView.builder(
                itemCount: widget.photoMemoList.length,
                itemBuilder: (context, index) {
                  commentController.add(TextEditingController());
                  return Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: WebImage(
                        height: 200,
                        url: widget.photoMemoList[index].photoURL,
                        context: context,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.photoMemoList[index].title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(widget.photoMemoList[index].memo),
                          Text(
                              'Created by : ${widget.photoMemoList[index].createdBy}'),
                          Text(
                              'Created at : ${widget.photoMemoList[index].timestamp}'),
                          Text(
                              'Shared With : ${widget.photoMemoList[index].sharedWith}'),
                          Text(
                              'Image Labels : ${widget.photoMemoList[index].imageLabels}'),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField( 
                                  controller: commentController[index],
                                  decoration: InputDecoration(
                                    hintText: 'Comment here ...',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                splashRadius: 25,
                                splashColor: Colors.blue,
                                onPressed: () {
                                  con.addComment(index);
                                },
                                icon: Icon(Icons.send),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Controller {
  late _SharedWithState state;
  _Controller(this.state);

  PhotoMemo photoMemo = PhotoMemo();

  // CollectionReference commentsRef =
  //     FirebaseFirestore.instance.collection(Constant.COMMENTS_COLLECTION);

  // void addComment(int index) async {
  //   String text = state.commentController[index].text;
  //   print(text);
  //   if (text.length <= 2) {
  //     print('type sth more');
  //     return;
  //   }

  //   Map<String, dynamic> newMap = Map();
  //   newMap['content'] = text;
  //   String timestamp = DateTime.now().toString();
  //   newMap['timestamp'] = timestamp;
  //   newMap['createdBy'] = state.widget.photoMemoList[index].createdBy;
  //   newMap['originalPoster'] = FirebaseAuth.instance.currentUser!.email;
  //   newMap['photo_memo_url'] = state.widget.photoMemoList[index].photoURL;
  //   commentsRef.add(newMap).then((value) {
  //     print(value);
  //   });

  //   resetValues(index);
  // }

  // resetValues(int index) {
  //   state.commentController[index].clear();
  // }

  void addComment(int index) async {
    FirestoreController.addComment(
        index, state.commentController, state.widget.photoMemoList);
  }
}
