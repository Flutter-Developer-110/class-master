import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/viewscreen/signup_screen.dart';
import 'package:lesson3/viewscreen/userhome_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  late _Controller con;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'PhotoMemo',
                  style: TextStyle(fontFamily: 'RockSalt', fontSize: 40.0),
                ),
                Text(
                  'Sign in Please!',
                  style: TextStyle(fontFamily: 'RockSalt', fontSize: 24.0),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter Email',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.purpleAccent,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: kLavender,
                        width: 1,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter Password',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.purpleAccent,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: kLavender,
                        width: 1,
                      ),
                    ),
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: con.signIn,
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: con.signUp,
                  child: Text(
                    'Create a new account',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _SignInState state;
  _Controller(this.state);
  String? email;
  String? password;

  void signUp() {
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('.') && value.contains('@')))
      return 'Invalid Email Address';
    else
      return null;
  }

  void saveEmail(String? value) {
    if (value != null) email = value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'Invalid password';
    else
      return null;
  }

  void savePassword(String? value) {
    if (value != null) password = value;
  }

  void signIn() async {
    FormState? currentState = state.formkey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();
    User? user;
    MyDialog.circularProgressStart(state.context);
    try {
      if (email == null || password == null) {
        throw 'Email or Password is null';
      }
      user = await FirebaseAuthController.signIn(
          email: email!, password: password!);
      //print('========= ${user?.email}');
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoList(email: email!); 
          
      MyDialog.circularProgressStop(state.context);

      Navigator.pushNamed(
        state.context,
        UserHomeScreen.routeName,
        arguments: {
          ARGS.USER: user,
          ARGS.PhotoMemoList: photoMemoList,
        },
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('======== signIn error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Sign in error: $e',
        seconds: 30,
      );
    }
  }
}
