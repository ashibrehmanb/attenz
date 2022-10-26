import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../databases/sql_helper.dart';
import 'finalattendance.dart';

class ScreenSemStudents extends StatefulWidget {
  final String batch;
  const ScreenSemStudents(this.batch, {super.key});

  @override
  State<ScreenSemStudents> createState() => _ScreenSemStudentsState();
}

class _ScreenSemStudentsState extends State<ScreenSemStudents> {
  List _journals = [];
  void _refreshSem() async {
    final data = await SQLHelper.getSemFromAttendance(widget.batch);
    setState(() {
      _journals = data;
    });
    // Loading the diary when the app starts
  }

  @override
  void initState() {
    super.initState();
    _refreshSem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch),
        centerTitle: true,
      ),
      body: (_journals.isEmpty)
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/markattendance empty.json", height: 500),
                Text(
                  "List is Empty!\nAdd Attendance to ${widget.batch}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ))
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Padding(
                    padding: (index == _journals.length - 1)
                        ? const EdgeInsets.symmetric(
                            horizontal: 26.5, vertical: 20)
                        : const EdgeInsets.only(
                            left: 26.5, right: 26.5, top: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScreenFinalAttendance(
                                widget.batch, _journals[index]['sem']),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 100,
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Text(
                              _journals[index]['sem'],
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
    );
  }
}
