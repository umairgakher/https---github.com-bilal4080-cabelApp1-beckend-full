// Import necessary packages
// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, prefer_final_fields, deprecated_member_use, avoid_print, library_private_types_in_public_api, use_key_in_widget_constructors, unused_import, prefer_const_constructors_in_immutables, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LatestPollScreen extends StatefulWidget {
  @override
  _LatestPollScreenState createState() => _LatestPollScreenState();
}

class _LatestPollScreenState extends State<LatestPollScreen> {
  final CollectionReference _pollsCollection =
      FirebaseFirestore.instance.collection('polls');
  User? user;
  int? checkuser;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    // Retrieve user data from Firestore and set it to `checkuser`
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          checkuser = data['checkuser'];
        });
      }
    }).catchError((error) {
      print("Error fetching user data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Poll',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff392850),
      ),
      body: _buildLatestPoll(),
    );
  }

  Widget _buildLatestPoll() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pollsCollection
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No polls available.'));
        }

        final pollData = snapshot.data!.docs[0].data() as Map<String, dynamic>;
        final pollId = snapshot.data!.docs[0].id;
        final poll = Poll.fromMap(pollData, pollId);

        return PollCard(poll: poll, checkuser: checkuser);
      },
    );
  }
}

class Poll {
  final String id;
  final String question;
  final List<String> options;
  final Map<String, int> votes;
  final Map<String, dynamic> userVotes;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
    required this.userVotes,
  });

  factory Poll.fromMap(Map<String, dynamic> data, String documentId) {
    return Poll(
      id: documentId,
      question: data['question'] ?? "N/A",
      options: List<String>.from(data['options'] ?? []),
      votes: Map<String, int>.from(data['votes'] ?? {}),
      userVotes: Map<String, dynamic>.from(data['user_votes'] ?? {}),
    );
  }
}

class PollCard extends StatelessWidget {
  final Poll poll;
  final int? checkuser;

  PollCard({required this.poll, this.checkuser});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            title: Text(
              poll.question + "?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Column(
            children: poll.options.map((option) {
              final userHasVoted = poll.userVotes.containsKey(user!.uid);

              return ListTile(
                title: Text(option),
                trailing: userHasVoted
                    ? Icon(Icons.done,
                        color: Colors
                            .green) // Display a "Done" icon if the user has voted
                    : checkuser == 0
                        ? IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () => _vote(poll.id, option),
                          )
                        : Text('Votes: ${poll.votes[option]}'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _vote(String pollId, String option) async {
    User? user = FirebaseAuth.instance.currentUser;
    final pollReference =
        FirebaseFirestore.instance.collection('polls').doc(pollId);
    final pollSnapshot = await pollReference.get();
    final pollData = pollSnapshot.data() as Map<String, dynamic>;

    if (pollData != null && pollData['options'].contains(option)) {
      final votes = pollData['votes'] as Map<String, dynamic> ?? {};
      final currentCount = votes[option] ?? 0;

      // Check if the user's UID already exists in the user_votes map
      if (pollData['user_votes'] is Map<String, dynamic> &&
          pollData['user_votes'][user!.uid] != null) {
        // Show a toast message that the user has already voted
        Fluttertoast.showToast(
          msg: 'You have already voted for this poll.',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xff392850),
          textColor: Colors.white,
        );
      } else {
        // If the user hasn't voted, update the user_votes map
        votes[option] = currentCount + 1;

        // Create a map to store the user's vote with their UID
        Map<String, dynamic> userVoteMap =
            pollData['user_votes'] as Map<String, dynamic>? ?? {};
        userVoteMap[user!.uid] = option;

        await pollReference.update({'votes': votes, 'user_votes': userVoteMap});
      }
    }
  }
}
