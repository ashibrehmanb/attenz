import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScreenSearch extends StatefulWidget {
  final List rollno, regno, name, percentage;
  const ScreenSearch(this.rollno, this.regno, this.name, this.percentage,
      {super.key});

  @override
  State<ScreenSearch> createState() => _ScreenSearchState();
}

List<Map<String, dynamic>>? _allUsers;

class _ScreenSearchState extends State<ScreenSearch> {
  void _setDefault() {
    setState(() {
      _allUsers = [];
      for (int i = 0; i < widget.rollno.length; i++) {
        _allUsers!.add({
          'rollno': widget.rollno[i],
          'regno': widget.regno[i],
          'name': widget.name[i],
          'percentage': widget.percentage[i],
        });
      }
    });
  }

  // final List<Map<String, dynamic>> _allUsers = [
  //   {"id": 1, "name": "Andrew", "age": 29},
  //   {"id": 2, "name": "Aragon", "age": 40},
  //   {"id": 3, "name": "Bob", "age": 5},
  //   {"id": 4, "name": "Barbara", "age": 35},
  //   {"id": 5, "name": "Candy", "age": 21},
  //   {"id": 6, "name": "Colin", "age": 55},
  //   {"id": 7, "name": "Audra", "age": 30},
  //   {"id": 8, "name": "Banana", "age": 14},
  //   {"id": 9, "name": "Caversky", "age": 100},
  //   {"id": 10, "name": "Becky", "age": 32},
  // ];
// This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];
  @override
  initState() {
    _setDefault();
    // at the beginning, all users are shown
    _foundUsers = _allUsers!;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers!;
    } else {
      results = _allUsers!
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // The search area here
            title: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: TextField(
                onChanged: (value) => _runFilter(value),
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    hintText: 'Search Name...',
                    border: InputBorder.none),
              ),
            ),
          ),
        )),
        body: _foundUsers.isNotEmpty
            ? ListView.builder(
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) => Card(
                  //key: ValueKey(_foundUsers[index]["regno"]),
                  color: Colors.grey.shade300,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _foundUsers[index]['rollno'],
                      ),
                    ),
                    trailing: Text(
                      _foundUsers[index]['percentage'],
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(_foundUsers[index]['name']),
                    subtitle: Text(_foundUsers[index]["regno"]),
                  ),
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Lottie.asset("assets/search.json", height: 150),
                    const Text(
                      "No matches found! Try different keyword",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ));
  }
}
