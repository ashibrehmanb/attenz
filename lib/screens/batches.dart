import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../databases/sql_helper.dart';

class ScreenBatches extends StatefulWidget {
  const ScreenBatches({Key? key}) : super(key: key);

  @override
  ScreenBatchesState createState() => ScreenBatchesState();
}

class ScreenBatchesState extends State<ScreenBatches> {
  // All journals
  List _journals = [];
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getBatches();
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

  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

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
              Row(
                children: [
                  Expanded(
                    //course Field
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      controller: _courseController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _canClose = false;
                          return 'Course required';
                        } else {
                          _canClose = true;
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          labelText: 'Course',
                          prefixIcon: Icon(Icons.format_list_numbered)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    //Year Field
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4)
                      ],
                      controller: _yearController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _canClose = false;
                          return 'Year required';
                        } else if (value.length < 4) {
                          _canClose = false;
                          return 'Invalid Year';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          labelText: 'Year',
                          prefixIcon: Icon(Icons.numbers)),
                    ),
                  ),
                ],
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
        _courseController.text = '';
        _yearController.text = '';
      },
    );
  }

// Insert a new journal to the database
  Future _addItem() async {
    await SQLHelper.createBatch(_courseController.text.trim().toUpperCase(),
        _yearController.text.trim());
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(String course, String year) async {
    await SQLHelper.deleteBatch(course, year);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        content: Text(
          'Successfully deleted batch(es)',
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
          'Batches',
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
                        "List is Empty!\nAdd Batches to the list",
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
                          (index + 1).toString().padLeft(2, '0'),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        _journals[index]['course'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _journals[index]['year'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteItem(
                              _journals[index]['course'],
                              _journals[index]['year']),
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
