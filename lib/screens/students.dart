import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../databases/sql_helper.dart';
import 'studentdetails.dart';

class ScreenStudents extends StatefulWidget {
  final String? batch;
  const ScreenStudents(this.batch, {Key? key}) : super(key: key);

  @override
  ScreenStudentsState createState() => ScreenStudentsState();
}

class ScreenStudentsState extends State<ScreenStudents> {
  // All journals
  List _journals = [];
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItemsonBatch(widget.batch!);
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _rollnoController = TextEditingController();
  final TextEditingController _regnoController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _canClose = true;

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(String? regno) async {
    if (regno != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['regno'] == regno);
      _rollnoController.text = existingJournal['rollno'];
      _regnoController.text = existingJournal['regno'];
      _nameController.text = existingJournal['name'];
      _addressController.text = existingJournal['address'];
      _guardianController.text = existingJournal['guardian'];
      _phoneController.text = existingJournal['phone'];
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
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    //Roll No. Field
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2)
                      ],
                      controller: _rollnoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _canClose = false;
                          return 'Roll No. required';
                        } else if (value == '0' || value == '00') {
                          return 'Invalid Roll No.';
                        } else {
                          _canClose = true;
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          labelText: 'Roll No.',
                          prefixIcon: Icon(Icons.format_list_numbered)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 8,
                    //Reg No. Field
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11)
                      ],
                      controller: _regnoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _canClose = false;
                          return 'Register No. required';
                        } else if (value.length < 11) {
                          _canClose = false;
                          return 'Invalid Register No.';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          labelText: 'Register No.',
                          prefixIcon: Icon(Icons.numbers)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                //Name field
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim() == '') {
                    _canClose = false;
                    return 'Name required';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                //Address field
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                controller: _addressController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.house)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                //Guardian field
                controller: _guardianController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Guardian',
                    prefixIcon: Icon(Icons.man)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                //Phone field
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11)
                ],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone)),
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
                      if (regno == null) {
                        if (_journals.any((element) =>
                            element['rollno'] ==
                                _rollnoController.text.padLeft(2, '0') ||
                            element['regno'] == _regnoController.text)) {
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
                      // Edit updating journal
                      if (regno != null) {
                        if (_journals.any((element) =>
                            element['rollno'] ==
                                _rollnoController.text.padLeft(2, '0') ||
                            element['regno'] == _regnoController.text)) {
                          if (regno == _regnoController.text &&
                              _journals.firstWhere((element) =>
                                      element['regno'] == regno)['rollno'] ==
                                  _rollnoController.text) {
                            _updateItem(regno);
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
                          await _updateItem(regno);
                        }
                      }

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      // Close the bottom
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        regno == null ? 'Create New' : 'Update',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(regno == null
                          ? Icons.add
                          : Icons.file_upload_outlined)
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
        _rollnoController.text = '';
        _regnoController.text = '';
        _nameController.text = '';
        _addressController.text = '';
        _guardianController.text = '';
        _phoneController.text = '';
      },
    );
  }

// Insert a new journal to the database
  Future _addItem() async {
    await SQLHelper.createItem(
        _rollnoController.text.padLeft(2, '0'),
        _regnoController.text,
        _nameController.text.trim(),
        _addressController.text.trim(),
        _guardianController.text.trim(),
        _phoneController.text,
        widget.batch!);
    _refreshJournals();
  }

  // Update an existing journal
  Future _updateItem(String regno) async {
    await SQLHelper.updateItem(
        regno,
        _rollnoController.text.padLeft(2, '0'),
        _regnoController.text,
        _nameController.text.trim(),
        _addressController.text.trim(),
        _guardianController.text.trim(),
        _phoneController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Successfully updated journal(s)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(String regno) async {
    await SQLHelper.deleteItem(regno);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Successfully deleted journal(s)',
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
        title: Text(
          widget.batch!,
          style: const TextStyle(fontSize: 23),
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
                        "List is Empty!\nAdd Students to the list",
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
                    margin: (index == _journals.length - 1)
                        ? const EdgeInsets.fromLTRB(25, 20, 25, 20)
                        : const EdgeInsets.fromLTRB(25, 20, 25, 0),
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            _journals[index]['rollno'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          _journals[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _journals[index]['regno'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                ),
                                onPressed: () =>
                                    _showForm(_journals[index]['regno']),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteItem(_journals[index]['regno']),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ScreenStudentDetails(_journals[index]),
                            ),
                          );
                        }),
                  ),
                ),
    );
  }
}
