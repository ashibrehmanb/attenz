import 'package:attenz/databases/sql_helper.dart';
import 'package:flutter/material.dart';

class ScreenAttendanceDetails extends StatefulWidget {
  final String batch;
  final String sem;
  final String date;
  const ScreenAttendanceDetails(this.batch, this.sem, this.date, {super.key});

  @override
  State<ScreenAttendanceDetails> createState() =>
      _ScreenAttendanceDetailsState();
}

class _ScreenAttendanceDetailsState extends State<ScreenAttendanceDetails> {
  List _journals = [];
  void _refreshJournals() async {
    final data =
        await SQLHelper.getAttendance(widget.batch, widget.sem, widget.date);
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
      appBar: AppBar(
        title: Text(
          '${widget.batch}  |  ${widget.sem}  |  ${widget.date}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Roll No.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Register No.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Marked by',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: List.generate(
                _journals.length,
                (index) => DataRow(cells: [
                      DataCell(Text(_journals[index]['rollno'])),
                      DataCell(Text(_journals[index]['regno'])),
                      DataCell(Text(_journals[index]['status'],
                          style: (_journals[index]['status'] == 'Absent')
                              ? const TextStyle(color: Colors.red)
                              : null)),
                      DataCell(Text(_journals[index]['name'])),
                      DataCell(Text(_journals[index]['markedby'])),
                    ])),
          ),
        ),
      ),
    );
  }
}
