// ignore_for_file: deprecated_member_use, unused_local_variable, prefer_const_constructors, sort_child_properties_last, avoid_print, avoid_function_literals_in_foreach_calls, prefer_final_fields, library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:io';

import 'package:app/User/Services/paymnet_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String userId;
  String month;
  String username;

  Transaction(this.userId, this.month, this.username);
}

class ImageData {
  String imageUrl;
  DateTime time;

  ImageData(this.imageUrl, this.time);
}

class PaymentPic extends StatefulWidget {
  @override
  _PaymentPicState createState() => _PaymentPicState();
}

class _PaymentPicState extends State<PaymentPic> {
  @override
  void initState() {
    super.initState();
    // Call _fetchImageData in initState to fetch images when the widget is created
    _fetchImageData();
  }

  final picker = ImagePicker();
  List<ImageData> _imageDataList = [];

  // ... (Previous code)
  Future<void> _fetchImageData() async {
    // Ensure that userpayment().uid returns the correct UID
    String? userId = userpayment().uid;
    CollectionReference transactions =
        FirebaseFirestore.instance.collection('transactions');
    DocumentReference transactionDoc = transactions.doc(userId);

    print(transactionDoc);
    // Fetch the 'images' subcollection
    QuerySnapshot imagesSnapshot = await transactionDoc
        .collection('images')
        .orderBy('time', descending: true)
        .get();
    print(imagesSnapshot);

    // Clear the previous list before fetching new data
    // _imageDataList.clear();
    print("hello ali1");

    // Process each image document
    imagesSnapshot.docs.forEach((imageDoc) {
      // Check if 'imageUrl' and 'time' fields exist and are not null
      if (imageDoc['imageUrl'] != null && imageDoc['time'] != null) {
        String imageUrl = imageDoc['imageUrl'];

        // Use 'Timestamp' class to convert Firestore timestamp to DateTime
        Timestamp timestamp = imageDoc['time'];
        DateTime time = timestamp.toDate();

        print("Image URL: $imageUrl");
        print("Time: $time");

        // Create an ImageData object and add it to the list
        _imageDataList.add(ImageData(imageUrl, time));
      } else {
        print("Image document is missing 'imageUrl' or 'time' fields.");
      }
    });

    // Update the UI
    setState(() {});
  }

  // Function to show a dialog to select an image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _showImageDialog(File(pickedFile.path));
    }
  }

  // Function to show a dialog with the selected image
  Future<void> _showImageDialog(File imageFile) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.file(imageFile),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the image dialog
                      },
                      child:
                          Text('Cancel', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff392850),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _sendImageToDatabase(imageFile);
                        setState(() {});
                        Navigator.of(context).pop(); // Close the image dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff392850),
                      ),
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to send the image data to the database
  Future<void> _sendImageToDatabase(File imageFile) async {
    // Replace with actual username

    DateTime now = DateTime.now();
    int currentMonth = now.month;
    // Save the image to Firebase Storage
    Reference storageReference =
        FirebaseStorage.instance.ref().child('images/${DateTime.now()}.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    // Get the image URL from Firebase Storage
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Save image data to the database
    CollectionReference transactions =
        FirebaseFirestore.instance.collection('transactions');
    DocumentReference transactionDoc =
        transactions.doc(userpayment().uid); // Create a document with userId

    // Create or update the 'doc' field inside the document
    await transactionDoc.set({
      'userId': userpayment().uid,
      'doc': {
        'month': currentMonth,
        'username': userpayment().username,
        "email": userpayment().email,
      },
    }, SetOptions(merge: true));

    // Add image data to the 'images' subcollection
    CollectionReference imagesCollection = transactionDoc.collection('images');
    await imagesCollection.add({
      'imageUrl': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });

    print('Image sent to database');
  }

  // Function to fetch image data from the database
  Widget _buildImageList() {
    return ListView.builder(
      itemCount: _imageDataList.length,
      itemBuilder: (context, index) {
        ImageData imageData = _imageDataList[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Image.network(imageData.imageUrl),
            subtitle: Text('Time: ${imageData.time}'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Color(0xff392850),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color(0xff392850),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildImageList(),
            ),
          ],
        ),
      ),
    );
  }
}
