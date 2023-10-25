import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Userpolls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polls', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff453658),
      ),
      body: PollList(),
    );
  }
}

class PollList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('polls').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No polls available.');
        }

        final polls = snapshot.data!.docs;

        return ListView.builder(
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            final question = poll['question'] as String;
            final answers = poll['answers'] as List<dynamic>;

            return Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Question: $question',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (int i = 0; i < answers.length; i++)
                    ListTile(
                      title: Text(
                        'Answer ${i + 1}: ${answers[i]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(home: Userpolls()));
}
