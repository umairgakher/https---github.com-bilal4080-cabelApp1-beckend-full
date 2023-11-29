// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, prefer_const_constructors, unused_local_variable, unused_element, use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  String? currentMonthName;
  int? currentYear;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff453658),
        title: Text(
          'Call To Employee ',
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
                            Uri dialnumber =
                                Uri(scheme: 'tel', path: "${data?['uPhone']}");
                            callnumber(dialnumber);
                            // _makePhoneCall(phoneno);
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

  callnumber(Uri dialnumber) async {
    await launchUrl(dialnumber);
  }

  // directcall() async {
  //   await FlutterPhoneDirectCaller.callNumber('1234567890');
  // }
}
