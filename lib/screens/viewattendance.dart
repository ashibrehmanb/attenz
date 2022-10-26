import 'package:attenz/databases/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'semstudents.dart';

class ScreenViewAttendance extends StatefulWidget {
  const ScreenViewAttendance({Key? key}) : super(key: key);

  @override
  State<ScreenViewAttendance> createState() => _ScreenViewAttendanceState();
}

class _ScreenViewAttendanceState extends State<ScreenViewAttendance> {
  List<String> dropdownList = [];
  List _journals = [];
  void _refreshBatches() async {
    final data = await SQLHelper.getBatchesFromAttendance();
    setState(() {
      _journals = data;
    });
    // Loading the diary when the app starts
  }

  @override
  void initState() {
    super.initState();
    _refreshBatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Attendance'),
        centerTitle: true,
      ),
      body: (_journals.isEmpty)
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/markattendance empty.json", height: 500),
                const Text(
                  "List is Empty!\nAdd Attendance to the list",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                            builder: (context) => ScreenSemStudents(_journals[index]['batch']),
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
                              _journals[index]['batch'],
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
