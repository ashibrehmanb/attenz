import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../databases/sql_helper.dart';

class ScreenTeachers extends StatefulWidget {
  const ScreenTeachers({Key? key}) : super(key: key);

  @override
  ScreenTeachersState createState() => ScreenTeachersState();
}

class ScreenTeachersState extends State<ScreenTeachers> {
  // All journals
  List _journals = [];
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getTeachers();
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _canClose = true;

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
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
                keyboardType: TextInputType.text,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim() == '') {
                    _canClose = false;
                    return 'Name required';
                  } else {
                    _canClose = true;
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
                keyboardType: TextInputType.emailAddress,
                controller: _usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _canClose = false;
                    return 'Username required';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.abc_outlined)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _canClose = false;
                    return 'Password required';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.remove_red_eye)),
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
                        await _addItem();
                      }
                      // Close the bottom

                      if (!mounted) return;
                      Navigator.of(context).pop();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        'Create New',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.add)
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
        _nameController.text = '';
        _usernameController.text = '';
        _passwordController.text = '';
      },
    );
  }

// Insert a new journal to the database
  Future _addItem() async {
    await SQLHelper.createTeacher(_nameController.text.trim(),
        _usernameController.text, _passwordController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(String username) async {
    await SQLHelper.deleteTeacher(username);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Successfully deleted teacher(s)',
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
          'Teachers',
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
                      const Text("List is Empty!\nAdd Teachers to the list",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
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
                        _journals[index]['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _journals[index]['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteItem(_journals[index]['username']),
                        ),
                      ),
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) =>
                      //           ScreenStudentDetails(_journals[index]),
                      //     ),
                      //   );
                      // }
                    ),
                  ),
                ),
    );
  }
}
