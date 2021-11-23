//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/cupertino.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';

class FirestoreController{
  static Future<String> addPhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance.collection(Constant.PHOTOMEMO_COLLECTION)
    .add(photoMemo.toFirestoreDoc());
   return ref.id;//doc id

  }

  static Future<List<PhotoMemo>> getPhotoMemoList(
    {required String email,}
  )async {
     QuerySnapshot querySnapshot=await FirebaseFirestore.instance
     .collection(Constant.PHOTOMEMO_COLLECTION)
     //.collection(Constant.PHOTOMEMO_COLLECTION)
      .where(PhotoMemo.CREATED_BY,isEqualTo: email)
      .orderBy(PhotoMemo.TIMESTAMP,descending: true)
      .get();

      var result=<PhotoMemo>[];
     querySnapshot.docs.forEach((doc){
       if(doc.data() != null) {
         var document = doc.data() as Map<String, dynamic>;
          var p=PhotoMemo.fromFirestoreDoc(doc:document,docId:doc.id);
         if(p!=null){
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
   required List<String> searchLabels,//OR search
 }) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
   .collection(Constant.PHOTOMEMO_COLLECTION)
   .where(PhotoMemo.CREATED_BY,isEqualTo: createdBy)
   .where(PhotoMemo.IMAGE_LABELS,arrayContainsAny:searchLabels)
   .orderBy(PhotoMemo.TIMESTAMP,descending:true)
   .get();

   var results=<PhotoMemo>[];
   querySnapshot.docs
     .forEach((doc){
       var p =PhotoMemo.fromFirestoreDoc(doc:doc.data() as Map<String,dynamic>,docId: doc.id);
       if (p !=null) results.add(p);
     });
     return results;
 }

 static Future<void> deletePhotoMemo({
   required PhotoMemo photoMemo,
 }) async {
  await FirebaseFirestore.instance.collection(Constant.PHOTOMEMO_COLLECTION)
   .doc(photoMemo.docId)
   .delete();
 }
 static Future<List<PhotoMemo>> getPhotoMemoListSharedWith({
   required String email,
 })async {
   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                 .collection(Constant.PHOTOMEMO_COLLECTION)
                 .where(PhotoMemo.SHARED_WITH,arrayContains:email)
                 .orderBy(PhotoMemo.TIMESTAMP,descending:true)
                 .get();
                 var results=<PhotoMemo>[];
            querySnapshot.docs.forEach((doc){
              var p =PhotoMemo.fromFirestoreDoc(doc:doc.data() as Map<String ,dynamic>,docId: doc.id);
              if (p != null) results.add(p);

            });     
            return results;
 }
  
}

