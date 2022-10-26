import 'package:attenz/databases/sql_helper.dart';
import 'package:attenz/screens/percentage.dart';
import 'package:flutter/material.dart';

class ScreenShortage extends StatefulWidget {
  const ScreenShortage({Key? key}) : super(key: key);

  @override
  State<ScreenShortage> createState() => _ScreenAddAttendanceState();
}

class _ScreenAddAttendanceState extends State<ScreenShortage> {
  List<String> dropdownList = [];
  String? dropdownValueBatch, dropdownValueSemester;
  List _journals = [];
  void _refreshBatches() async {
    final data = await SQLHelper.getBatchesFromAttendance();
    setState(() {
      _journals = data;
      dropdownList = [];
      for (int i = 0; i < _journals.length; i++) {
        dropdownList.add((_journals[i]['batch']));
      }
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
        title: const Text('Attendance Shortage List'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              'Select Batch :',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    hint: const Text('--Select--'),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    isExpanded: true,
                    value: dropdownValueBatch,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green,
                    ),
                    elevation: 9,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValueBatch = newValue!;
                      });
                    },
                    items: dropdownList.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              'Select Semester :',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    hint: const Text('--Select--'),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    isExpanded: true,
                    value: dropdownValueSemester,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green,
                    ),
                    elevation: 9,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValueSemester = newValue!;
                      });
                    },
                    items: ['S1', 'S2', 'S3', 'S4', 'S5', 'S6']
                        .map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150.0),
            child: ElevatedButton(
              onPressed: () async {
                if (dropdownValueBatch != null &&
                    dropdownValueSemester != null) {
                  final rollno = [];
                  final regno = [];
                  final name = [];
                  final percentage = [];
                  final data1 =
                      await SQLHelper.getItemsonBatch(dropdownValueBatch!);
                  final data2 = await SQLHelper.getDatesFromAttendance(
                      dropdownValueBatch!, dropdownValueSemester!);
                  for (int i = 0; i < data1.length; i++) {
                      int presentcount = await SQLHelper.getCountPresent(
                          data1[i]['regno'], dropdownValueSemester!);
                    if (presentcount/data2.length<0.75) {
                      rollno.add(data1[i]['rollno']);
                      regno.add(data1[i]['regno']);
                      name.add(data1[i]['name']);
                      percentage.add(
                          '${((presentcount / data2.length) * 100).toStringAsFixed(2)}%');
                    }
                  }
                  if (!mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScreenPercentage(
                              dropdownValueBatch!,
                              dropdownValueSemester!,
                              rollno,
                              regno,
                              name,
                              percentage)));
                } else {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                      content: Text(
                        'Please select batch,semester and try again',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.domain_verification_outlined)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
