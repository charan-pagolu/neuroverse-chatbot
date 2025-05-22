import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_ChartData> _chartData = [];
  List<DocumentSnapshot> _journalEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJournalData();
  }

  Future<void> _fetchJournalData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('journal_entries')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    final docs = query.docs;

    setState(() {
      _journalEntries = docs;
      _chartData = _generateChartData(docs);
      _isLoading = false;
    });
  }

  List<_ChartData> _generateChartData(List<DocumentSnapshot> docs) {
    final Map<String, int> entryCount = {};
    for (var doc in docs) {
      final ts = (doc['timestamp'] as Timestamp).toDate();
      final date = DateFormat('MMM d').format(ts);
      entryCount[date] = (entryCount[date] ?? 0) + 1;
    }
    return entryCount.entries
        .map((e) => _ChartData(e.key, e.value))
        .toList();
  }

  Future<void> _addJournalEntry() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('journal_entries').add({
      'content': content,
      'timestamp': Timestamp.now(),
      'userId': user.uid,
    });

    _controller.clear();
    _fetchJournalData();
  }

  Widget _buildChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.bar_chart, size: 20),
              SizedBox(width: 8),
              Text(
                'Entry Frequency by Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            series: <CartesianSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                dataSource: _chartData,
                color: Colors.teal,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                xValueMapper: (_ChartData data, _) => data.date,
                yValueMapper: (_ChartData data, _) => data.count,
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPastEntries() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_journalEntries.isEmpty) {
      return const Text("No journal entries found.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(Icons.history, size: 20),
              SizedBox(width: 8),
              Text('Your Journal History',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _journalEntries.length,
          itemBuilder: (context, index) {
            final entry = _journalEntries[index];
            final content = entry['content'] ?? '';
            final ts = (entry['timestamp'] as Timestamp).toDate();
            final dateStr = DateFormat('MMM d, yyyy – hh:mm a').format(ts);
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                 onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => JournalDetailScreen(
        entry: entry,
        entryId: entry.id,
        content: content,
        timestamp: ts,
        onEdit: (newContent) async {
          await FirebaseFirestore.instance
              .collection('journal_entries')
              .doc(entry.id)
              .update({'content': newContent});
Navigator.pop(context);
          _fetchJournalData();
        },
        onDelete: () async {
          await FirebaseFirestore.instance
              .collection('journal_entries')
              .doc(entry.id)
              .delete();
Navigator.pop(context);
          _fetchJournalData();
        },
      ),
    ),
  );
},

                leading: const Icon(Icons.edit_note, color: Colors.teal),
                title: Text(content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(dateStr),
              ),
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📝 My Journal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChart(),
              const SizedBox(height: 20),
              _buildPastEntries(),
              const SizedBox(height: 20),
              const Divider(thickness: 1.5),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Write your thoughts...",
                ),
                maxLines: null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _addJournalEntry,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Entry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  final String date;
  final int count;

  _ChartData(this.date, this.count);
}
