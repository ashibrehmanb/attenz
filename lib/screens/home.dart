import 'package:attenz/databases/sql_helper.dart';
import 'package:attenz/screens/holidays.dart';
import 'package:attenz/screens/students.dart';
import 'package:lottie/lottie.dart';
import 'addattendance.dart';
import 'batches.dart';
import 'login.dart';
import 'shortage.dart';
import 'teachers.dart';
import 'viewattendance.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'viewpercentage.dart';

const college = 'UIT Kottarakara';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  ScreenHomeState createState() => ScreenHomeState();
}

class ScreenHomeState extends State<ScreenHome> {
  int _selectedIndex = 0;
  static const List _titleAppbar = [
    Text('Attendance'),
    Text('Students'),
    Text('Settings')
  ];
  List _journals = [];
  void _refreshBatches() async {
    final data = await SQLHelper.getBatches();
    setState(() {
      _journals = data;
    });
    // Loading the diary when the app starts
  }

  @override
  void initState() {
    super.initState();
    _refreshBatches(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    final List homeMenu = [
      //Attendance Section
      ListView(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenAddAttendance(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text(
                      'Add Attendance',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenViewAttendance(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text(
                      'View Attendance',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenViewPercentage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text(
                      'View Percentage',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenShortage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text(
                      'Attendance Shortage List',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      //Students Section
      (_journals.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/markattendance empty.json", height: 500),
                  const Text(
                    "List is Empty!\nAdd Batches to the list",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            )
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
                            builder: (context) => ScreenStudents(
                                _journals[index]['course'] +
                                    ' ' +
                                    _journals[index]['year']),
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
                              _journals[index]['course'] +
                                  ' ' +
                                  _journals[index]['year'],
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

      //Settings section
      (admin)
          ? Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenBatches(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'Batches',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenTeachers(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'Teachers',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScreenHolidays())),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'Holidays',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _onClose(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScreenHolidays())),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'Holidays',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _onClose(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/adminlog.json", height: 200),
                        const Text(
                          "Login as Admin to access more Privileges",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Center(child: _titleAppbar.elementAt(_selectedIndex)),
      ),
      body: Center(
        child: homeMenu.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
        child: GNav(
          backgroundColor: Colors.green,
          activeColor: Colors.green,
          color: Colors.white,
          tabBackgroundColor: Colors.white,
          gap: 20,
          padding: const EdgeInsets.all(18),
          tabs: const [
            GButton(
              icon: Icons.calendar_month_outlined,
              text: 'Attendance',
            ),
            GButton(
              icon: Icons.person,
              text: 'Students',
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
              _refreshBatches();
            });
          },
        ),
      ),
    );
  }

  void _onClose() {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text(
                'Alert',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text('Are you sure you want to Log Out?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const ScreenLogin()),
                          (Route<dynamic> route) => false);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                          content: Text(
                            'Logged Out Successfully!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('Yes',
                        style: TextStyle(fontWeight: FontWeight.bold)))
              ],
            )));
  }
}
