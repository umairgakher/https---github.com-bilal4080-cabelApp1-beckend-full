// ignore_for_file: use_key_in_widget_constructors, camel_case_types, prefer_final_fields, library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Polls_admin extends StatefulWidget {
  @override
  _Polls_adminState createState() => _Polls_adminState();
}

class _Polls_adminState extends State<Polls_admin> {
  TextEditingController _questionController = TextEditingController();
  List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _createPoll() {
    try {
      String question = _questionController.text;
      List<String> answers =
          _answerControllers.map((controller) => controller.text).toList();

      if (question.isEmpty) {
        _showError('Please enter the question.');
      } else if (answers.length < 2 || answers.length > 4) {
        _showError('Please provide between 2 and 4 answers.');
      } else if (answers.any((answer) => answer.isEmpty)) {
        _showError('Please enter all answers.');
      } else {
        // All fields are filled, proceed to post the poll
        createPoll(question, answers);

        print('Question: $question');
        print('Answers: $answers');
      }
    } catch (error, stackTrace) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> createPoll(String question, List<String> answers) async {
    // Add a new poll document to the 'polls' collection
    DocumentReference pollRef = await _firestore.collection('polls').add({
      'question': question,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add answers to the 'answers' subcollection
    for (String answer in answers) {
      await pollRef.collection('answers').add({
        'text': answer,
        'count': 0, // Initialize count to 0
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addAnswer() {
    if (_answerControllers.length >= 4) {
      // Maximum answer limit reached, show a dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Maximum Answers Reached'),
            content: Text('You can add a maximum of four answers.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _answerControllers.add(TextEditingController());
      });
    }
  }

  void _removeAnswer(int index) {
    if (_answerControllers.length > 2) {
      setState(() {
        _answerControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Poll',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff453658),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Answers:'),
              SizedBox(height: 8.0),
              for (int i = 0; i < _answerControllers.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: _answerControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Answer ${i + 1}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    if (i > 1)
                      ElevatedButton(
                        onPressed: () {
                          _removeAnswer(i);
                        },
                        child: Text('Remove'),
                      ),
                  ],
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addAnswer,
                child: Text('Add Answer'),
              ),
              ElevatedButton(
                onPressed: _createPoll,
                child: Text('Post Poll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
