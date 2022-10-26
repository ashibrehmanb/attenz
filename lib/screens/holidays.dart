import 'package:attenz/screens/holidaydetails.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../databases/sql_helper.dart';
import 'login.dart';

class ScreenHolidays extends StatefulWidget {
  const ScreenHolidays({Key? key}) : super(key: key);

  @override
  ScreenHolidaysState createState() => ScreenHolidaysState();
}

class ScreenHolidaysState extends State<ScreenHolidays> {
  // All journals
  List _journals = [];
  DateTime date = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getHolidays();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _holidateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _canClose = true;

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(String? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['holidate'] == id);
      _holidateController.text = existingJournal['holidate'];
      _descController.text = existingJournal['desc'];
      _remarksController.text = existingJournal['remarks'];
    } else {
      _holidateController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // this will prevent the soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
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
                      _holidateController.text =
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    });
                  }
                },
                keyboardType: TextInputType.none,
                controller: _holidateController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.date_range)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _descController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _canClose = false;
                    return 'Description required';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.data_array_rounded)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Remarks',
                    prefixIcon: Icon(Icons.description_outlined)),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 220.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    _formKey.currentState!.validate();
                    if (_canClose) {
                      // Save new journal
                      if (id == null) {
                        if (_journals.any((element) =>
                            element['holidate'] == _holidateController.text)) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              content: Text(
                                'Failed to add item due to redundancy',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        } else {
                          await _addItem();
                        }
                      }
                      // Close the bottom
                      if (id != null) {
                        if (_journals.any((element) =>
                            element['holidate'] ==
                                _holidateController.text)) {
                          if (id == _holidateController.text) {
                            _updateItem(id);
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Failed to update item due to redundancy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        } else {
                          await _updateItem(id);
                        }
                      }
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        id == null ? 'Create New' : 'Update',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(id == null ? Icons.add : Icons.file_upload_outlined)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ).whenComplete(
      () {
        _holidateController.text = '';
        _descController.text = '';
        _remarksController.text = '';
      },
    );
  }

// Insert a new journal to the database
  Future _addItem() async {
    await SQLHelper.createHolidays(_holidateController.text,
        _descController.text.trim(), _remarksController.text.trim());
    _refreshJournals();
  }

//Update journal
  Future _updateItem(String holidate) async {
    await SQLHelper.updateHoliday(holidate, _holidateController.text,
        _descController.text.trim(), _remarksController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Successfully updated holiday(s)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(String holidate) async {
    await SQLHelper.deleteHoliday(holidate);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Successfully deleted holiday(s)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Holidays',
          style: TextStyle(fontSize: 23),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 17.0, top: 8, bottom: 15),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              textColor: Colors.green,
              color: Colors.white,
              onPressed: () {
                _showForm(null);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    'Add   ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.add_box),
                ],
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          //students list
          : (_journals.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/empty list.json", height: 100),
                      const Text(
                        "List is Empty!\nAdd Teachers to the list",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                            monthFind(_journals[index]['holidate']),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          _journals[index]['desc'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _journals[index]['holidate'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: (admin)?Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                ),
                                onPressed: () =>
                                    _showForm(_journals[index]['holidate']),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteItem(_journals[index]['holidate']),
                              ),
                            ],
                          ):null,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ScreenHolidayDetails(_journals[index]),
                            ),
                          );
                        }),
                  ),
                ),
    );
  }

  String monthFind(String date) {
    date = date.substring(3, 5);
    switch (date) {
      case '01':
        date = 'Jan';
        break;
      case '02':
        date = 'Feb';
        break;
      case '03':
        date = 'Mar';
        break;
      case '04':
        date = 'Apr';
        break;
      case '05':
        date = 'May';
        break;
      case '06':
        date = 'Jun';
        break;
      case '07':
        date = 'Jul';
        break;
      case '08':
        date = 'Aug';
        break;
      case '09':
        date = 'Sep';
        break;
      case '10':
        date = 'Oct';
        break;
      case '11':
        date = 'Nov';
        break;
      case '12':
        date = 'Dec';
        break;
    }
    return date;
  }
}
