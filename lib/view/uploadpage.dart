import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reels/utils/round_button.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? galleryFile;
  final picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _uploadReelToFirestore() async {
    final storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('reels')
        .child(DateTime.now().toString() + '.mp4');
    try {
      await storageRef.putFile(galleryFile!);
      final videoUrl = await storageRef.getDownloadURL();
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('reels').add({
        'videoLink': videoUrl,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'uid': 'yty', // Replace with actual user ID
        'nLikes': 0,
      });
      Fluttertoast.showToast(msg: "Uploaded successfully!");
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        galleryFile = null;
      });
    } catch (error) {
      print('Error uploading reel: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Reel'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RoundButton(
                title: 'Select video from Gallery',
                onTap: () {
                  _pickVideoFromGallery();
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: galleryFile == null
                    ? const Center(child: Text('No video selected'))
                    : Center(child: Text(galleryFile!.path)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              RoundButton(
                title: 'Upload',
                onTap: () {
                  if (galleryFile != null) {
                    _uploadReelToFirestore();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a video')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideoFromGallery() async {
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        galleryFile = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video selected')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
