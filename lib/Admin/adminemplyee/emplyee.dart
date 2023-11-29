// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, prefer_const_constructors, unused_local_variable, unused_element, use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Bill {
  final String userName;
  final double amount;
  bool isPaid;

  Bill({required this.userName, required this.amount, this.isPaid = false});
}

class callemplyee extends StatefulWidget {
  const callemplyee({Key? key}) : super(key: key);

  @override
  _BillsUserState createState() => _BillsUserState();
}

class _BillsUserState extends State<callemplyee> {
  List<Bill> bills = [];
  SharedPreferences? _prefs;
  String? currentMonthName;
  int? currentYear;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    final savedBills = _prefs?.getStringList('bills');

    if (savedBills != null) {
      bills = savedBills.map((billStr) {
        final billData = billStr.split(';');
        return Bill(
          userName: billData[0],
          amount: double.parse(billData[1]),
          isPaid: billData[2] == 'true',
        );
      }).toList();
    } else {
      bills = [
        Bill(userName: 'Sample User 1', amount: 50.0, isPaid: true),
        Bill(userName: 'Sample User 2', amount: 75.0, isPaid: false),
      ];
    }

    setState(() {});
  }

  Future<void> _saveData() async {
    final billStrings = bills.map((bill) {
      return '${bill.userName};${bill.amount};${bill.isPaid}';
    }).toList();
    await _prefs?.setStringList('bills', billStrings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff453658),
        title: Text(
          'callemplyee Salaries',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("checkuser", isEqualTo: 2)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return Center(
              child: Text(
                'No users yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                QueryDocumentSnapshot document = documents[index];
                Map<String, dynamic>? data =
                    documents[index].data() as Map<String, dynamic>?;
                var name = data?['username'];
                var email = data?["email"];
                var phoneno = data?['uPhone'];
                // var status = data?["status"];
                return Card(
                  elevation: 4, // Control the shadow or elevation of the card
                  margin: EdgeInsets.all(8), // Adjust the margin as needed
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Customize the border radius
                    side: BorderSide(
                        color: Color(0xff392850),
                        width: 1.0), // Customize the border color and width
                  ),
                  child: ListTile(
                    // Your ListTile content here
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Name: $name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.call),
                          onPressed: () {
                            _makePhoneCall(phoneno);
                          },
                        )
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email:$email"),
                        Text("Phone no: $phoneno")
                      ],
                    ),
                    // Add other ListTile properties as needed
                  ),
                );
              });
        },
      ),
    );
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && await canLaunch('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      // Handle error: Unable to launch the phone dialer
      print('Error: Unable to make the phone call');
    }
  }

  void _showEditDialog(String index, String name, double total) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit salary '),
          content: Text('Change payment status for ?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Add salary '),
              onPressed: () {
                _addNewBill(index, name);
              },
            ),
            TextButton(
              child: Text('Mark as Paid'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(index)
                    .update({"paid": 1});
                setState(() {});
                Navigator.pop(context);
                setState(() {
                  final now = DateTime.now();
                  currentYear = now.year;
                  final currentMonth = now.month;
                  final monthNames = [
                    '', // Index 0 is left empty since months are 1-based
                    'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November',
                    'December'
                  ];
                  currentMonthName = monthNames[currentMonth];
                  print('Current Month: $currentMonthName');
                });
                await FirebaseFirestore.instance
                    .collection("salary")
                    .doc()
                    .set({
                  "month": currentMonthName,
                  "year": currentYear,
                  "salary": total,
                  "paid": "paid",
                  "name": name,
                  "empId": index,
                });
              },
            ),
            TextButton(
              child: Text('Mark as Unpaid'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(index)
                    .update({"paid": 0});
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBill(int index) {
    setState(() {
      bills.removeAt(index);
    });
  }

  void _addNewBill(String index, String name) {
    showDialog(
      context: context,
      builder: (context) {
        double amount = 0.0;

        return AlertDialog(
          title: Text('Add New salary '),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name),
              SizedBox(
                height: 3,
              ),
              TextField(
                onChanged: (value) {
                  amount = double.tryParse(value) ?? .0;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Amount '),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Add salary  '),
              onPressed: () async {
                final userDoc = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(index)
                    .get();

                if (mounted) {
                  // Check if the widget is still active
                  if (userDoc.exists) {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(index)
                        .update({"salary": amount});

                    setState(
                        () {}); // Call setState if the widget is still active
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _saveData(); // Save data before disposing the state
    super.dispose();
  }

  canLaunch(String s) {}
}
