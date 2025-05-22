import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _moodCollection = "mood_entries";
  static final String _patternCollection = "mood_patterns";

  static String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  /// Save today's mood with timestamp and userId
  static Future<void> saveMood(String mood) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await _firestore.collection(_moodCollection).add({
      'mood': mood,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': _userId,
      'date': today,
    });

    print("✅ Mood saved: $mood on $today for user $_userId");
  }

  /// Fetch last 3 moods for current user
  static Future<List<String>> getLastThreeMoods() async {
    final snapshot = await _firestore
        .collection(_moodCollection)
        .where('userId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    List<String> moods = snapshot.docs
        .map((doc) => doc['mood'].toString().substring(0, 1).toUpperCase())
        .toList();

    print("📊 Last 3 moods for $_userId: $moods");
    return moods.reversed.toList();
  }

  /// Return pattern like GBB for current user
  static Future<String> getMoodPatternCode() async {
    final moods = await getLastThreeMoods();
    final pattern = moods.map((m) => m.toLowerCase() == 'good' ? 'G' : 'B').join();
    print("🧠 Mood Pattern for $_userId: $pattern");
    return pattern;
  }

  /// Get both pattern and mood list
  static Future<Map<String, dynamic>> getMoodData() async {
    final moods = await getLastThreeMoods();
    final pattern = moods.map((m) => m.toLowerCase() == 'good' ? 'G' : 'B').join();
    return {
      'moodList': moods,
      'patternCode': pattern,
    };
  }

  /// Save pattern with userId
  static Future<void> saveMoodPattern(List<String> moods) async {
    final pattern = moods.map((m) => m.toLowerCase() == 'good' ? 'G' : 'B').join();
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection(_patternCollection).add({
      "pattern": pattern,
      "timestamp": timestamp,
      "userId": _userId,
    });

    print("✅ Mood pattern '$pattern' saved for user $_userId");
  }

  /// Save both mood and pattern
  static Future<void> saveMoodAndPattern(String mood) async {
    await saveMood(mood);
    final lastThree = await getLastThreeMoods();
    if (lastThree.length == 3) {
      await saveMoodPattern(lastThree);
    }
  }
}
