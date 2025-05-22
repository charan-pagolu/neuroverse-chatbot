import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_helper.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final CollectionReference moodsCollection =
    FirebaseFirestore.instance.collection('moods');

  // ✅ Save mood to Firestore under userId
  Future<void> saveMood(String mood) async {
    if (userId == null) return;

    await _firestore.collection('moods').add({
      'mood': mood,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }

  // ✅ Save mood + mood pattern
  Future<void> saveMoodAndPattern(String mood) async {
  await saveMood(mood);

  final last3Moods = await fetchLast3Moods();

  if (last3Moods.length == 3 && userId != null) {
    await FirebaseFirestore.instance.collection('mood_patterns').add({
      'pattern': last3Moods.join(),
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId, // ✅ Add this line to tag mood pattern with current user
    });
  }
}


  // ✅ Last 3 moods for this user
  Future<List<String>> fetchLast3Moods() async {
    if (userId == null) return [];

    final querySnapshot = await _firestore
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    return querySnapshot.docs
        .map((doc) => (doc['mood'] ?? '').toString())
        .toList()
        .reversed
        .toList();
  }

  // ✅ Last 7 moods for line chart (filtered by userId)
  Future<List<String>> fetchLast7Moods(String userId) async {
  final querySnapshot = await moodsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(7)
      .get();
  return querySnapshot.docs
      .map((doc) => (doc['mood'] ?? '').toString())
      .toList()
      .reversed
      .toList();
}


  // ✅ Mood patterns for this user
  Future<List<String>> fetchMoodPatterns(String userId) async {
  final query = await FirebaseFirestore.instance
      .collection('mood_patterns')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(50)
      .get();
  return query.docs.map((doc) => doc['pattern'] as String).toList();
 }

}
