import 'package:cloud_firestore/cloud_firestore.dart';

class Reel {
  final String title;
  final String description;
  final String videoLink;
  final String uid;
  final int nLikes;

  Reel({
    required this.title,
    required this.description,
    required this.videoLink,
    required this.uid,
    required this.nLikes,
  });

  Map<String, dynamic> toFirebaseDocument() {
    return {
      'title': title,
      'description': description,
      'videoLink': videoLink,
      'uid': uid,
      'nLikes': nLikes,
    };
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> toFirebaseDocumentSnapshot() {
    return FirebaseFirestore.instance.collection('reels').doc(uid).snapshots().first;
  }
}
