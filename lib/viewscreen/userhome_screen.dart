//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/replies_comments.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  final User user;
  late final String displayName;
  late final String email;
  final List<PhotoMemo> photoMemoList;
  UserHomeScreen({required this.user, required this.photoMemoList}) {
    displayName = user.displayName ?? 'N/A';
    email = user.email ?? 'no email';
  }
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  @override
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey();
  Stream<QuerySnapshot> commentsRef =
      FirebaseFirestore.instance.collection('comments').snapshots();

  Stream<QuerySnapshot> replies =
      FirebaseFirestore.instance.collection('replies').snapshots();

  Comments comments = Comments(); 
  String commentsLength = '';

  late TextEditingController commentController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);

    commentController = TextEditingController();
    commentsLength = commentsRef.length.toString();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    commentController.dispose();
    super.dispose();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false), //disable Android system back button
      child: Scaffold(
        appBar: AppBar(
          //title: Text('User Home'),
          actions: [
            con.delIndexes.isEmpty
                ? Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: con.cancelDelete,
                  ),
            con.delIndexes.isEmpty
                ? IconButton(
                    onPressed: con.search,
                    icon: Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: con.delete,
                    icon: Icon(
                      Icons.delete,
                    )),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.displayName),
                accountEmail: Text(widget.email),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Shared with'),
                onTap: con.sharedWith,
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              ),
              ListTile(
                  leading: Icon(Icons.comment),
                  title: Text('Comment & Replies'),
                  onTap: () {
                    con.goRepliesPage();
                  }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: con.photoMemoList.isEmpty
            ? Text(
                'No Photo Memo Found',
                style: Theme.of(context).textTheme.headline6,
              )
            : ListView.builder(
                itemCount: con.photoMemoList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 10,
                    color: con.delIndexes.contains(index)
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    child: ListTile(
                      leading: WebImage(
                        url: con.photoMemoList[index].photoURL,
                        context: context,
                      ),
                      trailing: Icon(Icons.arrow_right),
                      title: Text(con.photoMemoList[index].title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            con.photoMemoList[index].memo.length >= 40
                                ? con.photoMemoList[index].memo.substring(
                                      0,
                                      40,
                                    ) +
                                    '...'
                                : con.photoMemoList[index].memo,
                          ),
                          Text(
                            'Created by : ${con.photoMemoList[index].createdBy}',
                            style: GoogleFonts.inter(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'SharedWith : ${con.photoMemoList[index].sharedWith}',
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Timestamp : ${con.photoMemoList[index].timestamp}',
                            style: GoogleFonts.inter(
                              color: Colors.yellow,
                              fontSize: 14,
                            ),
                          ),
                          Stack(
                            children: [
                              commentsLength == commentsRef.length.toString() ? Icon(Icons.chat) : Icon(Icons.new_label_outlined),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Text('${comments.originalPoster.length}'),
                              )
                            ],
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: commentsRef,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading");
                              } else {
                                return Container(
                                  height: 80,
                                  child: ListView(
                                    children: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      Map<String, dynamic> data = document
                                          .data()! as Map<String, dynamic>;
                                      return GestureDetector(
                                        onTap: () {
                                          if (widget.photoMemoList[index]
                                                  .createdBy ==
                                              data['originalPoster']) {
                                            return;
                                          }
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ), //this right here
                                                child: Container(
                                                  height: 200,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'Sender : ${data['originalPoster']}'),
                                                        Text(
                                                            'Comment : ${data['content']}'),
                                                        Divider(
                                                            height: 2,
                                                            color: Colors.red),
                                                        Expanded(
                                                          child: Container(),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    commentController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      'Reply to ${data['originalPoster']} ...',
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              splashRadius: 25,
                                                              splashColor:
                                                                  Colors.blue,
                                                              onPressed: () {
                                                                con.replyComment(
                                                                    index);
                                                              },
                                                              icon: Icon(
                                                                  Icons.send),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: ListTile(
                                          title: widget.photoMemoList[index]
                                                      .sharedWith
                                                      .contains(data[
                                                          'originalPoster']) &&
                                                  widget.photoMemoList[index]
                                                          .createdBy ==
                                                      data['createdBy']
                                              ? Text(
                                                  'Sender : ${data['originalPoster']}',
                                                )
                                              : Text(''),
                                          subtitle: widget.photoMemoList[index]
                                                      .sharedWith
                                                      .contains(data[
                                                          'originalPoster']) &&
                                                  widget.photoMemoList[index]
                                                          .createdBy ==
                                                      data['createdBy']
                                              ? Text(
                                                  'Comment : ${data['content']}')
                                              : Text(''),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => con.onTap(index),
                      onLongPress: () => con.onLongPress(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Controller {
  late _UserHomeState state;

  late List<PhotoMemo> photoMemoList;

  String? searchKeyString;
  List<int> delIndexes = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWith(
              email: state.widget.email);
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ARGS.PhotoMemoList: photoMemoList,
            ARGS.USER: state.widget.user,
          });
      Navigator.of(state.context).pop(); //close the drawer
    } catch (e) {
      if (Constant.DEV) print('========= sharedWith error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get sharedWith list: $e',
      );
    }
  }

  void delete() async {
    MyDialog.circularProgressStart(state.context);
    delIndexes.sort(); //ascending order
    for (int i = delIndexes.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[delIndexes[i]];
        await FirestoreController.deletePhotoMemo(photoMemo: p);
        await CloudStorageController.deletePhotoFile(photoMemo: p);
        state.render(() {
          photoMemoList.removeAt(delIndexes[i]);
        });
        //photoMemoList.removeAt(delIndexes[i]);
      } catch (e) {
        if (Constant.DEV) print('======== failed to delete photomemo: $e');
        MyDialog.showSnackBar(
          context: state.context,
          message: 'Failed to delete Photomemo: $e',
        );
        break; //quit further processing
      }
    }
    MyDialog.circularProgressStop(state.context);
    state.render(() => delIndexes.clear());
  }

  void replyComment(int index) {
    FirestoreController.replyComment(
        index, state.commentController, photoMemoList);

    state.commentController.clear();
  }

  void cancelDelete() {
    state.render(() {
      delIndexes.clear();
    });
  }

  void onLongPress(int index) {
    state.render(() {
      if (delIndexes.contains(index))
        delIndexes.remove(index);
      else
        delIndexes.add(index);
    });
    //print('========= delIndexes: $delIndexes');
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();
    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().toLowerCase());
      }
    }

    MyDialog.circularProgressStart(state.context);

    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        //read all photomemos
        results = await FirestoreController.getPhotoMemoList(
            email: state.widget.email);
      } else {
        results = await FirestoreController.searchImages(
          createdBy: state.widget.email,
          searchLabels: keys,
        );
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() => photoMemoList = results);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('search error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Search error: $e',
      );
    }
  }

  void onTap(int index) async {
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
    //rerender home screen
    state.render(() {
      //reorder based on the updated timestamp
      photoMemoList.sort((a, b) {
        if (a.timestamp!.isBefore(b.timestamp!))
          return 1; //descending order
        else if (a.timestamp!.isAfter(b.timestamp!))
          return -1;
        else
          return 0;
      });
    });
  }

  void goRepliesPage() async {
    Navigator.push(state.context, MaterialPageRoute(builder: (context) {
      return RepliesComment(
        photoMemoList: state.widget.photoMemoList,
        user: state.widget.user,
      );
    }));
  }

  void addButton() async {
    //navigate to AddNewPhotoMemo Screen
    await Navigator.pushNamed(state.context, AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: photoMemoList,
        });
    state.render(() {});
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      if (Constant.DEV) print('========= sign out error: $e');
    }
    Navigator.of(state.context).pop(); //close the drawer
    Navigator.of(state.context).pop(); //pop from the user
  }
}
