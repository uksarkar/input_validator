import 'dart:math';

import 'package:flutter/material.dart';
import 'package:input_validator/input_validator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Validator"),
      ),
      body: InputValidator.form(
          context: context,
          child: (formState) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) async {
                            if (formState.add("username", value)) {
                              formState.setState = "CHECKING_USERNAME";
                              var isValid = await checkUsername(value);
                              if (!isValid) {
                                formState.setError(
                                    "username", "Username not available.");
                              } else {
                                formState.setError("username", null);
                              }
                              formState.setState = "STABLE";
                            }
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.person),
                            labelText: "Username",
                            errorText: formState.getError("username"),
                          ),
                        ),
                      ),
                      if (formState.currentState == "CHECKING_USERNAME")
                        CircularProgressIndicator()
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: TextField(
                    onChanged: (value) => formState.add("full_name", value),
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      labelText: "Full Name",
                      errorText: formState.getError("full_name"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: TextField(
                    onChanged: (value) => formState.add("email", value),
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: "Email",
                      errorText: formState.getError("email"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: TextField(
                    onChanged: (value) => formState.add("password", value),
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock_open),
                      labelText: "Password",
                      errorText: formState.getError("password"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ElevatedButton(
                    onPressed: !formState.hasError &&
                            formState.currentState != "CHECKING_USERNAME"
                        ? () {
                            if (formState.validate()) {
                              print(formState.formData);
                            } else {
                              print("Invalid input");
                            }
                          }
                        : null,
                    child: Text("Submit"),
                  ),
                ),
              ],
            );
          },
          fields: {
            "full_name": FieldData(rules: "required|min_length:4"),
            "email": FieldData(rules: "required|email"),
            "password": FieldData(
              rules: "required|min_length:6|max_length:16|strong",
              messages: {
                "strong": CustomHandler(
                  onHandle: (payload, _) {
                    String p =
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                    return payload != null && RegExp(p).hasMatch(payload)
                        ? null
                        : "Uppercase, Lowercase, Number and Symbles.";
                  },
                ),
              },
            ),
            "username": FieldData(rules: "required|min_length:4"),
          }),
    );
  }

  Future<bool> checkUsername(String value) {
    var used = ["test", "hello", "utpal", "sarkar"];
    int d = Random(0).nextInt(2);
    return Future.delayed(Duration(seconds: d), () {
      return !used.contains(value);
    });
  }
}
