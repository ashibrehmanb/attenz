import 'package:attenz/databases/sql_helper.dart';
import 'package:attenz/screens/login.dart';
import 'package:attenz/screens/markattendance.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'attendancedetails.dart';

class ScreenFinalAttendance extends StatefulWidget {
  final String batch;
  final String sem;
  const ScreenFinalAttendance(this.batch, this.sem, {super.key});

  @override
  State<ScreenFinalAttendance> createState() => _ScreenFinalAttendanceState();
}

class _ScreenFinalAttendanceState extends State<ScreenFinalAttendance> {
  
  Future<int> _presentcount(String attdate) async {
    final data = await SQLHelper.getWeightCount(
        "Present", widget.batch, widget.sem, attdate);
    return data.length;
  }

  Future<int> _absentcount(String attdate) async {
    final data = await SQLHelper.getWeightCount(
        "Absent", widget.batch, widget.sem, attdate);
    return data.length;
  }

  List _journals = [];
  late List _present;
  late List _absent;
  void _refreshJournals() async {
    _present = [];
    _absent = [];
    final data =
        await SQLHelper.getDatesFromAttendance(widget.batch, widget.sem);
    for (int i = 0; i < data.length; i++) {
      int present = await _presentcount(data[i]['attdate']);
      int absent = await _absentcount(data[i]['attdate']);

      setState(() {
        _present.add(present);
        _absent.add(absent);
      });
    }

    setState(() {
      _journals = data;
    });
  }

  @override
  void initState() {
    _refreshJournals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.batch}   |   ${widget.sem}'),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.grey[300],
                margin: const EdgeInsets.fromLTRB(25, 20, 25, 0),
                child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        (index + 1).toString().padLeft(2, '0'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      _journals[index]['attdate'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        "Present: ${_present[index]}    Absent: ${_absent[index]}"),
                    trailing: (admin)
                        ? SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                  ),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ScreenMarkAttendance(
                                                  widget.batch,
                                                  widget.sem,
                                                  _journals[index]['attdate'],
                                                  true))),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await SQLHelper.deleteAttendance(
                                        _journals[index]['attdate'],
                                        widget.batch);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          'Successfully deleted attendance(s)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                    _refreshJournals();
                                  },
                                ),
                              ],
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenAttendanceDetails(
                              widget.batch,
                              widget.sem,
                              _journals[index]['attdate']),
                        ),
                      );
                    }),
              ),
            ),
    );
  }
}
