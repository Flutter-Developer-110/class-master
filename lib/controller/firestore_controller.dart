//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';

class FirestoreController {
  static Future<String> addPhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.toFirestoreDoc());
    return ref.id; //doc id
  }


  static Future<String> addComment({
    required Comments comments,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.COMMENTS_COLLECTION)
        .add(comments.toFirestoreDoc());
    return ref.id; 
  }

  static Future<List<Comments>> getComment({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.COMMENTS_COLLECTION)
        //.collection(Constant.PHOTOMEMO_COLLECTION)
        .where(Comments.CREATED_BY, isEqualTo: email)
        .orderBy(Comments.TIMESTAMP, descending: true)
        .get();

    var result = <Comments>[];
    querySnapshot.docs.forEach((doc) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = Comments.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) {
          result.add(p);
        }
      }
    });
    return result;
  }

// //Adding a Comment to the Firestore
//   static Future<void> addComment(
//       int index,
//       List<TextEditingController> commentController,
//       List<PhotoMemo> photoMemoList) async {
//     CollectionReference commentsRef =
//         FirebaseFirestore.instance.collection(Constant.COMMENTS_COLLECTION);
//     String text = commentController[index].text;
//     print(text);
//     if (text.length <= 2) {
//       print('type sth more');
//       return;
//     }

//     Map<String, dynamic> newMap = Map();
//     newMap['content'] = text;
//     String timestamp = DateTime.now().toString();
//     newMap['timestamp'] = timestamp;
//     newMap['createdBy'] = photoMemoList[index].createdBy;
//     newMap['originalPoster'] = FirebaseAuth.instance.currentUser!.email;
//     newMap['photo_memo_url'] = photoMemoList[index].photoURL;
//     commentsRef.add(newMap).then((value) {
//       print(value);
//     });
//     commentController[index].clear();
//   }

  //Replying Comment's to the Firestore
  static Future<void> replyComment(
      int index,
      TextEditingController commentController,
      List<PhotoMemo> photoMemoList) async {
    CollectionReference commentsRef =
        FirebaseFirestore.instance.collection(Constant.REPLIES_COLLECTION);
    String text = commentController.text;
    print(text);
    if (text.length <= 2) {
      print('type sth more');
      return;
    }

    Map<String, dynamic> newMap = Map();
    newMap['content'] = text;
    String timestamp = DateTime.now().toString();
    newMap['timestamp'] = timestamp;
    newMap['sender'] = FirebaseAuth.instance.currentUser!.email;
    newMap['receiver'] = photoMemoList[index].sharedWith; 
    commentsRef.add(newMap).then((value) {
      print(value);
    });
    commentController.clear();
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        //.collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = PhotoMemo.fromFirestoreDoc(doc: document, docId: doc.id);
        if (p != null) {
          result.add(p);
        }
      }
    });
    return result;
  }

  static Future<void> updatePhotoMemo({
    required String docId,
    required Map<String, dynamic> updateInfo,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<List<PhotoMemo>> searchImages({
    required String createdBy,
    required List<String> searchLabels, //OR search
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var results = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      var p = PhotoMemo.fromFirestoreDoc(
          doc: doc.data() as Map<String, dynamic>, docId: doc.id);
      if (p != null) results.add(p);
    });
    return results;
  }

  static Future<void> deletePhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(photoMemo.docId)
        .delete();
  }

  static Future<List<PhotoMemo>> getPhotoMemoListSharedWith({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
    var results = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      var p = PhotoMemo.fromFirestoreDoc(
          doc: doc.data() as Map<String, dynamic>, docId: doc.id);
      if (p != null) results.add(p);
    });
    return results;
  }
}
