// ignore_for_file: prefer_const_constructors, avoid_print, use_key_in_widget_constructors

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(MyApp());
}

String prettyPrint(Map json) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
  }

  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      print("is Logged:::: ${prettyPrint(accessToken.toJson())}");
      // now you can call to  FacebookAuth.instance.getUserData();
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
      log("shubham${_userData as dynamic}");
    }
  }

  void _printCredentials() {
    print(
      prettyPrint(_accessToken!.toJson()),
    );
  }

  Future<void> _login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      //_printCredentials();
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _userData = userData;
    } else {
      print(result.status);
      print(result.message);
    }

    setState(() {
      _checking = false;
    });
  }

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Facebook Auth '),
        ),
        body: _checking
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _userData != null
                                  ? "Name=>${_userData!["name"]}"
                                  : "NO LOGGED",
                            ),
                            Text(
                              _userData != null
                                  ? "Email=>${_userData!["email"]}"
                                  : "NO LOGGED",
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Image.network(
                                _userData != null
                                    ? "${_userData!["picture"]['data']['url']}"
                                    : "https://metabiomedamericas.com/wp-content/uploads/2018/05/facebook-avatar-1024x645.jpg",
                                width: 200,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      CupertinoButton(
                        color: Colors.blue,
                        child: Text(
                          _userData != null ? "LOGOUT" : "LOGIN",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _userData != null ? _logOut : _login,
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
