// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, sort_child_properties_last

import 'package:app/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegScreen extends StatefulWidget {
  const RegScreen({Key? key}) : super(key: key);

  @override
  State<RegScreen> createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController uPhonenoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  bool isPasswordVisible = false;
  bool isCPasswordVisible = false;
  String selectedRadioValue = 'Option 1';
  int? driver = 0;

  void handleRadioValueChange(String value) {
    setState(() {
      selectedRadioValue = value;
    });
  }

  bool _validateFields() {
    var username = usernameController.text.trim();
    var uemail = emailController.text.trim();
    var upassword = passwordController.text.trim();
    var uphone = uPhonenoController.text.trim();
    var ucpassword = cpasswordController.text.trim();

    if (username.isEmpty ||
        uemail.isEmpty ||
        upassword.isEmpty ||
        ucpassword.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff392850),
        textColor: Colors.white,
      );
      return false;
    }

    if (!RegExp(
            r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
        .hasMatch(uemail)) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 7, 80, 140),
        textColor: Colors.white,
      );
      return false;
    }

    if (upassword != ucpassword) {
      Fluttertoast.showToast(
        msg: "Passwords do not match",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff392850),
        textColor: Colors.white,
      );
      return false;
    }

    if (upassword.length < 8 ||
        !upassword.contains(RegExp(r'[A-Z]')) ||
        !upassword.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Password must be at least 8 characters long and contain at least one capital letter and one number'),
        ),
      );
      return false;
    }

    if (uphone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone must be at least 11 digits long'),
        ),
      );
      return false;
    }

    return true;
  }

  void _createAccount(int a) async {
    if (!_validateFields()) {
      return;
    }

    var username = usernameController.text.trim();
    var uemail = emailController.text.trim();
    var upassword = passwordController.text.trim();
    var uphone = uPhonenoController.text.trim();

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: uemail,
        password: upassword,
      );

      User? user = userCredential.user;
      if (user != null) {
        a == 1
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                "username": username,
                "email": uemail,
                "password": upassword,
                "createdId": DateTime.now(),
                "uPhone": uphone,
                "profileImage": " ",
                'salary': 0,
                "userId": user.uid,
                "checkuser": 2,
                "paid": 0,
              })
            : await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                "username": username,
                "email": uemail,
                "password": upassword,
                "createdId": DateTime.now(),
                "uPhone": uphone,
                "profileImage": " ",
                'salary': 0,
                "userId": user.uid,
                "checkuser": 0,
                "paid": 0,
                "service": "Basic",
              });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => loginScreen()),
        );
      }
    } catch (e) {
      print("Error creating account: $e");
      Fluttertoast.showToast(
        msg: "Error creating account: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff392850),
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    uPhonenoController.dispose();
    passwordController.dispose();
    cpasswordController.dispose();
    super.dispose();
  }

  Widget _header() {
    return Column(
      children: const [
        SizedBox(
          height: 60,
        ),
        Text(
          "Create Account",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter details to get started"),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 40,
        ),
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: "Username",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Email id",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: uPhonenoController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Phone no",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.phone_android),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock_outline_sharp),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
              child: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          obscureText: !isPasswordVisible,
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: cpasswordController,
          decoration: InputDecoration(
            hintText: "Retype Password",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock_outline_sharp),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  isCPasswordVisible = !isCPasswordVisible;
                });
              },
              child: Icon(
                isCPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          obscureText: !isCPasswordVisible,
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () => _createAccount(0),
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff392850),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Sign up as an Employee?"),
            TextButton(
              onPressed: () => _createAccount(1),
              child: const Text(
                "Sign up",
                style: TextStyle(color: Color(0xff392850)),
              ),
            ),
          ]),
        )
      ],
    );
  }

  Widget _loginInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => loginScreen()),
            );
          },
          child: const Text(
            "Login",
            style: TextStyle(color: Color(0xff392850)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(),
                _inputFields(),
                _loginInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
