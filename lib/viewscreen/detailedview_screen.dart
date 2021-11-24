//import 'dart:html';

import 'dart:io';
//import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/googleML_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  final User user;
  final PhotoMemo photoMemo;

  DetailedViewScreen({required this.user, required this.photoMemo});

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  late _Controller con;
  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? progressMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed View',
        ),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: Icon(Icons.check))
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: con.edit,
                )
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.yellow,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                        radius: 67,
                        backgroundImage: con.photo == null
                            ? WebImage()
                            : FileImage(con.photo!) as ImageProvider),
                  ), 
                  editMode
                      ? Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent,
                      child: PopupMenuButton(
                        icon: Icon(Icons.photo, color: Colors.white),
                        onSelected: con.getPhoto,
                        itemBuilder: (context) => [
                          for (var source in PhotoSource.values)
                            PopupMenuItem(
                              value: source,
                              child: Text('${source.toString().split('.')[1]}'),
                            ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
              progressMessage == null
                  ? SizedBox(
                      height: 1.0,
                    )
                  : Text(
                      progressMessage!,
                      style: Theme.of(context).textTheme.headline6,
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: editMode,
                  style: Theme.of(context).textTheme.headline6,
                  decoration: InputDecoration(
                      hintText: 'Enter Title',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  initialValue: con.tempMemo.title,
                  autocorrect: true,
                  validator: PhotoMemo.validateTitle,
                  onSaved: con.saveTitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: editMode,
                  style: Theme.of(context).textTheme.bodyText1,
                  decoration: InputDecoration(
                      hintText: 'Enter Memo',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  initialValue: con.tempMemo.memo,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  autocorrect: true,
                  validator: PhotoMemo.validateMemo,
                  onSaved: con.saveMemo,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: editMode,
                  style: Theme.of(context).textTheme.bodyText1,
                  decoration: InputDecoration(
                      hintText: 'Enter shared with Email list',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  initialValue: con.tempMemo.sharedWith.join(','),
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  autocorrect: false,
                  validator: PhotoMemo.validateSharedWith,
                  onSaved: con.saveSharedWith,
                ),
              ),
              Constant.DEV
                  ? Text('Image Labels by ML\n${con.tempMemo.imageLabels}')
                  : SizedBox(
                      height: 1.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _DetailedViewState state;
  late PhotoMemo tempMemo;
  File? photo;

  _Controller(this.state) {
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.CAMERA
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return; //canceled by camera or gallery.
      state.render(() => photo = File(image.path));
    } catch (e) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get a picture: $e',
      );
    }
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    MyDialog.circularProgressStart(state.context);
    try {
      Map<String, dynamic> updateInfo = {};
      if (photo != null) {
        Map photoInfo = await CloudStorageController.uploadPhotoFile(
          photo: photo!,
          uid: state.widget.user.uid,
          filename: tempMemo.photoFilename,
          listener: (int progress) {
            state.render(() {
              state.progressMessage =
                  progress == 100 ? null : 'Uploading: $progress %';
            });
          },
        );
        //generate image lables by Ml
        List<String> recognitions =
            await GoogleMLController.getImageLabels(photo: photo!);
        tempMemo.imageLabels = recognitions;
        tempMemo.photoURL = photoInfo[ARGS.DownloadURL];
        updateInfo[PhotoMemo.PHOTO_URL] = tempMemo.photoURL;
        updateInfo[PhotoMemo.IMAGE_LABELS] = tempMemo.imageLabels;
      }
      //update Firestore doc
      if (tempMemo.title != state.widget.photoMemo.title)
        updateInfo[PhotoMemo.TITLE] = tempMemo.title;
      if (tempMemo.memo != state.widget.photoMemo.memo)
        updateInfo[PhotoMemo.MEMO] = tempMemo.memo;
      if (!listEquals(tempMemo.sharedWith, state.widget.photoMemo.sharedWith))
        updateInfo[PhotoMemo.SHARED_WITH] = tempMemo.sharedWith;

      if (updateInfo.isNotEmpty) {
        //changes have been made
        tempMemo.timestamp = DateTime.now();
        updateInfo[PhotoMemo.TIMESTAMP] = tempMemo.timestamp;
        await FirestoreController.updatePhotoMemo(
          docId: tempMemo.docId!,
          updateInfo: updateInfo,
        );
        state.widget.photoMemo.assign(tempMemo);
      }
      MyDialog.circularProgressStop(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('========= update photomemo error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Upsate Photomemo error. $e',
      );
    }
    // state.render(() => state.editMode = false);
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void saveTitle(String? value) {
    if (value != null) tempMemo.title = value;
  }

  void saveMemo(String? value) {
    if (value != null) tempMemo.memo = value;
  }

  void saveSharedWith(String? value) {
    if (value != null && value.trim().length != 0) {
      tempMemo.sharedWith.clear();
      tempMemo.sharedWith.addAll(value.trim().split(RegExp('{, |}+')));
    }
  }
}
