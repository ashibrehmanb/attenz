import 'package:attenz/databases/sql_helper.dart';

import 'home.dart';
import 'package:flutter/material.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({Key? key}) : super(key: key);

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

bool admin = false;
late String user;

class _ScreenLoginState extends State<ScreenLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  List _journals = [];
  void _refreshJournals() async {
    final data = await SQLHelper.getTeachers();
    setState(() {
      _journals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              Image.asset(
                'assets/attendzicon.png',
                height: 100,
              ),
              const SizedBox(height: 25),
              Text(
                (admin) ? 'WELCOME ADMIN!' : 'WELCOME TEACHER!',
                style:
                    const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  RadioListTile(
                    title: const Text("Teacher"),
                    value: false,
                    groupValue: admin,
                    onChanged: (value) {
                      setState(() {
                        admin = false;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text("Admin"),
                    value: true,
                    groupValue: admin,
                    onChanged: (value) {
                      setState(() {
                        admin = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    checkLogin(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/kulogo.png',
                height: 80,
              ),
              const Text(
                'University Institute Of Technology',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('University Of Kerala'),
              const Text('Kottarakara'),
              const Text('Email: uit.ktr@gmail.com'),
              const Text('Website: www.uitktr.in'),
              const Text('PH: 0474 2452220'),
              const SizedBox(
                height: 20,
              ),
              const Text(
                  'Created by: Ashib Rehman B, Abhay S Shabu, Ganesh Raj'),
              const Text('(BCA Minor Project 2020-2023)',style: TextStyle(fontSize: 10),)
            ],
          ),
        ));
  }

  void checkLogin(BuildContext context) {
    final username = _usernameController.text;
    final password = _passwordController.text;
    String? usern;
    String? pass;
    if (admin) {
      user = 'Admin';
      usern = 'admin';
      pass = 'password';
    } else {
      for (int i = 0; i < _journals.length; i++) {
        if (_journals[i]['username'] == _usernameController.text) {
          user = _journals[i]['name'];
          usern = _usernameController.text;
          pass = _journals[i]['password'];
        }
      }
    }
    if (username == usern && password == pass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreenHome(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Logged in as $user',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Error! Please check login details and try again.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
