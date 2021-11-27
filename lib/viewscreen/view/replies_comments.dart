import 'dart:async';
import 'dart:ui';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/photomemo.dart';

class RepliesComment extends StatefulWidget {
  final User user;
  final List<PhotoMemo> photoMemoList;
  const RepliesComment(
      {Key? key, required this.user, required this.photoMemoList})
      : super(key: key);

  @override
  _RepliesCommentState createState() => _RepliesCommentState();
}

class _RepliesCommentState extends State<RepliesComment> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference messageRef =
      FirebaseFirestore.instance.collection('replies');
  late TextEditingController controller;
  late _Controller con;
  ScrollController scrollController = ScrollController();

  String updatingMessage = '';
  bool isEditing = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    con = _Controller(this);
  }

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: messageRef
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      reverse: true,
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map(
                        (doc) {
                          Map data = doc.data() as Map;
                          bool isMe = data['sender'] == auth.currentUser!.email;
                          return Bubble(
                            margin: BubbleEdges.only(
                                top: 10,
                                left: isMe ? 10 : 0,
                                right: !isMe ? 10 : 0),
                            nip:
                                (isMe) ? BubbleNip.rightTop : BubbleNip.leftTop,
                            color: (isMe)
                                ? const Color.fromRGBO(225, 255, 199, 1)
                                : Colors.white,
                            alignment:
                                (isMe) ? Alignment.topRight : Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['sender'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  data['content'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  data['timestamp'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    );
                  } //
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Visibility(
                    visible: isEditing,
                    child: Container(
                      width: size.width - 65,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(225, 255, 199, 1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          topLeft: Radius.circular(4),
                        ),
                      ),
                      child: Text(updatingMessage),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                          minLines: 1,
                          maxLines: 5,
                          onTap: () {
                            Timer(
                              const Duration(milliseconds: 300),
                              () {
                                scrollController.jumpTo(
                                    scrollController.position.minScrollExtent);
                              },
                            );
                          },
                          controller: controller,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Enter your message',
                            hintStyle: TextStyle(color: Colors.black),
                          )),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),
                      onPressed: con.sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}

class _Controller {
  late _RepliesCommentState state;
  _Controller(this.state);

  void sendMessage() async {
    String text = state.controller.text;
    print(text);
    if (text.length <= 2) {
      print('type sth more');
      return;
    }

    Map<String, dynamic> newMap = Map();
    newMap['content'] = text;
    String timestamp = DateTime.now().toString();
    newMap['timestamp'] = timestamp;
    newMap['sender'] = state.auth.currentUser!.email;
    state.messageRef.add(newMap).then((value) {
      print(value);
    });
    state.controller.clear();
  }
}
