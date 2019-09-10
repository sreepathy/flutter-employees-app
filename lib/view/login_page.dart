import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syndicate_login/utils/text_validators.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

import '../widget/loader.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscure = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _form = new GlobalKey<FormState>();
  bool _autovalidate = false;
  String _email, _password;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.redAccent,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    "Let's Start with Login!",
                    style: textTheme.headline.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Material(
                    elevation: 20,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                            key: _form,
                            autovalidate: _autovalidate,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  validator: TextValidators.validateEmail,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.alternate_email),
                                      labelText: 'Email',
                                      hintText: 'Email'),
                                  onSaved: (text) {
                                    setState(() {
                                      _email = text;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  validator: TextValidators.validatePassword,
                                  keyboardType: TextInputType.text,
                                  obscureText: obscure,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                          icon: Icon(Icons.remove_red_eye,
                                              color: obscure
                                                  ? theme.disabledColor
                                                  : Colors.redAccent),
                                          onPressed: () {
                                            setState(() {
                                              obscure = !obscure;
                                            });
                                          }),
                                      labelText: 'Password',
                                      hintText: 'Password'),
                                  onSaved: (text) {
                                    setState(() {
                                      _password = text;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                RaisedButton(
                                  onPressed: onSubmitted,
                                  elevation: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      'Login',
                                      style: textTheme.subhead
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                  color: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                RaisedButton(
                                  onPressed: () {},
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      'Login with Google',
                                      style: textTheme.subhead
                                          .copyWith(color: Colors.redAccent),
                                    ),
                                  ),
                                  color: Colors.red.shade50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'I forgot password ?',
                  textAlign: TextAlign.center,
                  style: textTheme.body2,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "I don't have an account",
                  textAlign: TextAlign.center,
                  style: textTheme.body2,
                )
              ],
            ),
          ),
          isLoading ? Loader() : SizedBox()
        ],
      ),
    );
  }

  onSubmitted() async {
    final FormState form = _form.currentState;
    if (!form.validate()) {
      //NOT VALIDATED
      print(
          'Not Validated - @email: ${_emailController.text}, @password: ${_passwordController.text}');
      setState(() {
        _autovalidate = true; // Start validating on every change.
      });
    } else {
      //VALIDATED
      form.save();
      print('Validated - @email: $_email, @password: $_password');
      setState(() {
        isLoading = true;
      });
      validateUser();
    }
  }

  validateUser() {
    Map<String, String> header = {
      'Accept': '*/*',
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    String data = 'user=$_email&pass=$_password';

    http
        .post('https://webapp.syndicatebank.in/api/api.php',
            body: data, headers: header)
        .then((response) async {
      if (response != null) {
        if (response.body == 'login success; Welcome A') {
          print(response.body);
          SharedPreferences _pref = await SharedPreferences.getInstance();
          _pref.setBool('isLoggedIn', true);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          print(response.body);
          showSnackbar(response.body);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        print('Response is Null');
      }
    });
  }

  showSnackbar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 14.0),
    )));
  }
}
