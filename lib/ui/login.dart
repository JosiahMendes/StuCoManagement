import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stuco2/ui/myhome.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;
  String _authHint = '';

  Widget hintText() {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(_authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 50),
                      child: Text("YCIS Qingdao \n Student Council",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            fontSize: 35.1,
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Login",
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          fontSize: 22,
                          //color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please enter email address';
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        maxLines: 1,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(15.0),
                              ),
                            ),
                            filled: true,
                            labelText: 'Email'),
                        onSaved: (input) => _email = input,
                      ),
                    ),
                    TextFormField(
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Please enter password';
                        }
                        if (input.length < 9) {
                          return 'Please enter 9 digit Student ID';
                        }
                      },
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      maxLines: 1,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(15.0),
                            ),
                          ),
                          filled: true,
                          labelText: 'Password'),
                      onSaved: (input) => _password = input,
                      obscureText: true,
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(top: 8.0),
                      child: RaisedButton(
                        padding: const EdgeInsets.all(8.0),
                        onPressed: signIn,
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(9.0),
                          ),
                        ),
                        child: Text('Sign in'),
                      ),
                    ),
                    hintText()
                  ],
                )),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        FirebaseUser user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: (MyHome(user: user)),
                ),
          ),
        );
      } catch (e) {
        print(e.message);
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
      }
    }
  }
}
