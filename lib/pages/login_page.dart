import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../service/authentication/auth_provider.dart';
import 'package:email_validator/email_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  AuthStatus authStatus = AuthStatus.notSignedIn;

  String? _username;
  String? _password;
  //var _userNameMinLength = 5;
  var formHasErrors = false;
  var loading = false;


  bool validateAndSave() {
    final form = formKey.currentState;
    //  remember form.validate() can be null, so
    //  perform a null check
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    _resetLoginError();
    _showLoader();
    if (validateAndSave()) {
      try {

        var auth = AuthProvider.of(context).auth;
        var user = await auth.requestLoginAPI(_username!, _password!);

        if(user.statusCode == 200)
        {
          print('Signed in as: ${user.body.firstName + user.body.lastName}');
          widget.onSignedIn();
        }
        else if(user.statusCode == 404)
        {
          _resetLoader();
          _showLoginError();
        }
        else{
          _resetLoader();
          _showLoginError();
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  /*void GoToRegister(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage(onSignedIn: widget.onSignedIn)),
    );
  }*/

  void _showLoginError(){
    setState(() {
      formHasErrors = true;
    });
  }

  void _resetLoginError(){
    setState(() {
      formHasErrors = false;
    });
  }

  void _showLoader(){
    setState(() {
      loading = true;
    });
  }

  void _resetLoader(){
    setState(() {
      loading = false;
    });
  }


  String? validateName(String stringVal, int minLength, String fieldName) {
    if (stringVal.length < minLength) {
      return '$fieldName must be a minimum of $minLength charaters';
    } else {
      return null;
    }
  }

  String? validateUsername(String value){
    // it's a email
    var valid = EmailValidator.validate(value);
    if(valid == false) {
      return 'Please enter a valid email address.';
    } else {
      return null;
    }
  }

  String? validatePassword(String stringVal){
    if(stringVal.isEmpty) {
      return 'Please enter a valid password.';
    }
    return null;
  }


  @override
  Widget build(BuildContext context,) {

    return Scaffold(

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(),
                      child: Form(
                        //  Set the form key:
                        key: formKey,
                        child: Column(
                          //  Require all children to fill the cross axis
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            //  Username field
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'USERNAME',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)
                                ),
                            ),
                              validator: (value) => value!.isEmpty ? 'Email is required': validateUsername(value),
                              onSaved: (value) => _username = value,
                            ),

                            //  add some padding
                            const SizedBox(height: 20,),

                            //  Password field
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'PASSWORD',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue,
                                ),
                              ),
                            ),
                              obscureText: true,
                              validator: (value) => value!.isEmpty ? 'Password required' : validatePassword(value),
                              onSaved: (value) => _password = value,
                            ),

                            //  add some padding
                            const SizedBox(height: 20,),

                            ElevatedButton(
                              onPressed: validateAndSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                              child: const Text('Register'),
                            ),


                            const SizedBox( height: 20,),


                            Center(
                              child: loading? const CircularProgressIndicator()
                                  : const Center(),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

        ],
      ),
    );

  }
}