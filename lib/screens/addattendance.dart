import 'package:attenz/databases/sql_helper.dart';
import 'package:attenz/screens/markattendance.dart';
import 'package:flutter/material.dart';

class ScreenAddAttendance extends StatefulWidget {
  const ScreenAddAttendance({Key? key}) : super(key: key);

  @override
  State<ScreenAddAttendance> createState() => _ScreenAddAttendanceState();
}

class _ScreenAddAttendanceState extends State<ScreenAddAttendance> {
  List<String> dropdownList = [];
  String? dropdownValueBatch, dropdownValueSemester;
  DateTime date = DateTime.now();
  List _journals = [];
  void _refreshBatches() async {
    final data = await SQLHelper.getBatches();
    setState(() {
      _journals = data;
      dropdownList = [];
      for (int i = 0; i < _journals.length; i++) {
        dropdownList.add(
            (_journals[i]['course'] + ' ' + _journals[i]['year']).toString());
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
        title: const Text('Add Attendance'),
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
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              'Select Date :',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: GestureDetector(
              onTap: () async {
                var newDate = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2060),
                  builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        dialogTheme: DialogTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: child!),
                );
                if (newDate == null) {
                  return;
                } else {
                  setState(() {
                    date = newDate;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.green,
                        )
                      ],
                    )),
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
                  final test = await SQLHelper.getDatesFromAttendance(
                      dropdownValueBatch!, null);
                  final testlist = [];
                  for (int i = 0; i < test.length; i++) {
                    testlist.add(test[i]['attdate']);
                  }
                  if (testlist.any((element) =>
                      element ==
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}')) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        content: Text(
                          'Attendance already marked for this date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenMarkAttendance(
                            dropdownValueBatch!,
                            dropdownValueSemester!,
                            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                            false),
                      ),
                    );
                    return;
                  }
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
