import 'package:attenz/databases/sql_helper.dart';
import 'package:attenz/screens/finalattendance.dart';
import 'package:attenz/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScreenMarkAttendance extends StatefulWidget {
  final String batch;
  final String date;
  final String sem;
  final bool editEnabled;
  const ScreenMarkAttendance(this.batch, this.sem, this.date, this.editEnabled,
      {Key? key})
      : super(key: key);

  @override
  State<ScreenMarkAttendance> createState() => _ScreenMarkAttendanceState();
}

List<Color>? textColor;
List<Color>? backColor;
bool? _switchStatus;

class _ScreenMarkAttendanceState extends State<ScreenMarkAttendance> {
  List _journals = [];
  List _attendance = [];
  void setDefaultColors() async {
    final data = await SQLHelper.getItemsonBatch(widget.batch);
    final attdata =
        await SQLHelper.getAttendance(widget.batch, widget.sem, widget.date);
    setState(() {
      _journals = data;
      _attendance = attdata;
      textColor = [];
      backColor = [];
      _switchStatus = false;
      if (widget.editEnabled) {
        for (int i = 0; i < _attendance.length; i++) {
          textColor!.add(Colors.white);
          backColor!.add((_attendance[i]['status'] == 'Present')
              ? Colors.green
              : Colors.red);
        }
      } else {
        for (int i = 0; i < _journals.length; i++) {
          textColor!.add(Colors.black);
          backColor!.add(Colors.white);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setDefaultColors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '${widget.batch}  |  ${widget.sem}  |  ${widget.date}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        body: (_journals.isEmpty)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/markattendance empty.json",
                        height: 500),
                    Text(
                      "List is Empty!\nAdd Students to the batch\n'${widget.batch}'",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tap to change colors.\nGreen:Present   Red:Absent',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                                Switch(
                                    value: _switchStatus!,
                                    onChanged: ((value) => setState(() {
                                          if (backColor!.every((element) =>
                                              element == Colors.green)) {
                                            _switchStatus = true;
                                          } else {
                                            _switchStatus = value;
                                          }
                                          if (_switchStatus!) {
                                            for (int i = 0;
                                                i < _journals.length;
                                                i++) {
                                              textColor![i] = Colors.white;
                                              backColor![i] = Colors.green;
                                            }
                                          }
                                        }))),
                                const Text(
                                  'ALL PRESENT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                  Expanded(
                      flex: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView.builder(
                                      itemCount: (widget.editEnabled)
                                          ? _attendance.length
                                          : _journals.length,
                                      itemBuilder: (context, index) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: GestureDetector(
                                                onTap: () {
                                                  _switchStatus = false;
                                                  setState(() {
                                                    backColor![
                                                        index] = (backColor![
                                                                index] ==
                                                            Colors.white)
                                                        ? Colors.green
                                                        : (backColor![index] ==
                                                                Colors.green)
                                                            ? Colors.red
                                                            : Colors.white;
                                                    textColor![index] =
                                                        (backColor![index] ==
                                                                Colors.white)
                                                            ? Colors.black
                                                            : Colors.white;
                                                  });
                                                  if (backColor!.every(
                                                      (element) =>
                                                          element ==
                                                          Colors.green)) {
                                                    _switchStatus = true;
                                                  }
                                                },
                                                child: Container(
                                                    height: 40,
                                                    color: backColor![index],
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              _journals[index]
                                                                  ['rollno'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textColor![
                                                                          index]),
                                                            ),
                                                            const SizedBox(
                                                              width: 50,
                                                            ),
                                                            Text(
                                                              _journals[index]
                                                                  ['name'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textColor![
                                                                          index]),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          )),
                                ))),
                      )),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 130, vertical: 5),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)))),
                            onPressed: () {
                              if (backColor!.every(
                                  (element) => element != Colors.white)) {
                                final absenties = [];
                                for (int i = 0; i < _journals.length; i++) {
                                  if (backColor![i] == Colors.red) {
                                    absenties.add(_journals[i]['rollno']);
                                  }
                                }
                                showDialog(
                                    context: context,
                                    builder: ((context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          title: const Text(
                                            'Absenties',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Text((absenties.isEmpty)
                                              ? 'No absenties. All are present.'
                                              : absenties.join(', ')),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            TextButton(
                                                onPressed: () async {
                                                  for (int i = 0;
                                                      i < _journals.length;
                                                      i++) {
                                                    await SQLHelper
                                                        .createAttendance(
                                                            widget.date,
                                                            _journals[i]
                                                                ['regno'],
                                                            (backColor![i] ==
                                                                    Colors
                                                                        .green)
                                                                ? 'Present'
                                                                : 'Absent',
                                                            widget.sem,
                                                            user);
                                                  }
                                                  if (!mounted) return;

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  (widget.editEnabled)
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ScreenFinalAttendance(
                                                                    widget
                                                                        .batch,
                                                                    widget.sem),
                                                          ),
                                                        )
                                                      : null;
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      duration:
                                                          Duration(seconds: 3),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      backgroundColor:
                                                          Colors.green,
                                                      content: Text(
                                                        'Attendance added',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text('Submit',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ],
                                        )));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Please mark all students',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: const [
                                  Text(
                                    'Submit',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.send_and_archive_outlined)
                                ],
                              ),
                            )),
                      )),
                ],
              ));
  }
}
