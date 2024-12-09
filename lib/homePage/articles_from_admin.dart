import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticlesFromAdmin extends StatefulWidget {
  const ArticlesFromAdmin({super.key});

  @override
  State<ArticlesFromAdmin> createState() => _ArticlesFromAdminState();
}

class _ArticlesFromAdminState extends State<ArticlesFromAdmin> {
  String? accountName;
  String? accountEmail;
  // ignore: unused_field
  List<String> _messageIds = []; // List to hold document IDs for deletion
  List<Map<String, dynamic>> _messages =
      []; // List to hold messages with titles and timestamps

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch messages from 'ArticleMessages' collection
  }

  void _fetchMessages() async {
    try {
      // Fetch messages from Firestore collection 'ArticleMessages'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ArticleMessages')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _messages = snapshot.docs.map((doc) {
          return {
            'title': doc['title'] as String,
            'message': doc['message'] as String,
            'timestamp': doc['timestamp'] != null
                ? (doc['timestamp'] as Timestamp).toDate()
                : null, // Convert timestamp to DateTime if it exists
          };
        }).toList();
        _messageIds = snapshot.docs
            .map((doc) => doc.id)
            .toList(); // Store IDs for deletion if needed
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp != null) {
      // Format the timestamp to a readable date and time
      return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap:
                  true, // Ensures that GridView doesn't expand infinitely
              physics:
                  const NeverScrollableScrollPhysics(), // Prevents GridView from scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display 3 containers in a row
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1, // Adjusted to allow more vertical space
              ),

              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          (_messages[index]['title'] ?? '').toUpperCase(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                          softWrap: true, // Ensures text wraps
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        // Allow the message text to expand
                        child: SingleChildScrollView(
                          child: Text(
                            _messages[index]['message'] ?? '',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.start,
                            softWrap: true, // Ensures text wraps
                            overflow: TextOverflow
                                .visible, // Ensures text doesn't get clipped
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _formatTimestamp(_messages[index]['timestamp']),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ), // Display the formatted timestamp at the bottom
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
