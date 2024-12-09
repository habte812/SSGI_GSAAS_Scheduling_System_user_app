import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  _NotepadPageState createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  final User? user = FirebaseAuth.instance.currentUser; // Get current user
  late final CollectionReference notepadRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      notepadRef = FirebaseFirestore.instance
          .collection('UserNotepad')
          .doc(user!.uid)
          .collection('notes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        'All Notes',
        IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notepadRef.snapshots(), // Use the updated reference
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              return ListTile(
                title: Text(note['title']),
                subtitle: Text('Last Update: ${note['date']}'),
                leading: note['isImportant'] == true
                    ? const Icon(Icons.star, color: Colors.orange)
                    : const Icon(Icons.notes),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailPage(
                      note.id,
                      note['title'],
                      note['content'],
                      note['isImportant'] ?? false,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AddNotePage()));
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        "New note",
        IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              Lottie.asset(
                'assets/images/loadingAnimation.json',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
            else
              ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(
                    Color.fromARGB(255, 8, 5, 48),
                  ),
                  mouseCursor: const WidgetStatePropertyAll(
                    SystemMouseCursors.click,
                  ),
                ),
                onPressed: () async {
                  if (_titleController.text.isEmpty ||
                      _contentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Title and content cannot be empty',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return; // Stop execution if the fields are empty
                  }

                  setState(() {
                    _isLoading = true; // Start loading
                  });

                  final user =
                      FirebaseAuth.instance.currentUser; // Get current user
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('UserNotepad')
                        .doc(user.uid)
                        .collection('notes')
                        .add({
                      'title': _titleController.text,
                      'content': _contentController.text,
                      'date': DateTime.now().toString(),
                      'isImportant': false,
                    });
                    Navigator.pop(context);
                  }

                  setState(() {
                    _isLoading = false; // Stop loading
                  });
                },
                child: const Text(
                  'Save Note',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NoteDetailPage extends StatefulWidget {
  final String id, title, content;
  final bool isImportant;

  const NoteDetailPage(this.id, this.title, this.content, this.isImportant,
      {super.key});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late bool _isImportant;
  late String _title;
  late String _content;
  late DateTime _lastEdited;

  @override
  void initState() {
    super.initState();
    _isImportant = widget.isImportant;
    _title = widget.title;
    _content = widget.content;
    _lastEdited = DateTime.now(); // Default value for last edited time
  }

// Function to update the note in Firestore
  Future<void> _updateNote() async {
    _lastEdited =
        DateTime.now(); // Update the lastEdited time to the current time
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('UserNotepad')
          .doc(user.uid)
          .collection('notes')
          .doc(widget.id)
          .update({
        'title': _title,
        'content': _content,
        'isImportant': _isImportant,
        'date':
            _lastEdited.toString(), // Update the date field to the current date
        'lastEdited': _lastEdited, // Update the last edited time in Firestore
      });
    }
  }

  // Function to show an edit dialog for title and content
  Future<void> _showEditDialog() async {
    TextEditingController titleController = TextEditingController(text: _title);
    TextEditingController contentController =
        TextEditingController(text: _content);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('Edit Note'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _title = titleController.text;
                    _content = contentController.text;
                  });
                  await _updateNote();
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              )
            ]);
      },
    );
  }

  // Convert the DateTime to a readable format
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          _title.toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'F2'),
        ),
        actions: [
          IconButton(
            icon: Icon(_isImportant ? Icons.star : Icons.star_border),
            onPressed: () async {
              setState(() {
                _isImportant = !_isImportant;
              });

              // Show SnackBar if the note is marked as important (favorite)
              if (_isImportant) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Added to favorite',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
              if (!_isImportant) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Removed from favorite',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
              final user =
                  FirebaseAuth.instance.currentUser; // Get current user
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('UserNotepad')
                    .doc(user.uid)
                    .collection('notes')
                    .doc(widget.id)
                    .update({'isImportant': _isImportant});
              }
            },
            color: Colors.white,
          ),

          // Delete note button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final user =
                  FirebaseAuth.instance.currentUser; // Get current user
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('UserNotepad')
                    .doc(user.uid)
                    .collection('notes')
                    .doc(widget.id)
                    .delete();
                Navigator.pop(context);
              }
            },
            color: Colors.white,
          ),
          // Edit note button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(); // Show dialog to edit title and content
            },
            color: Colors.white,
          ),
        ],
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _content,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Text(
            //   "Last edited: ${_formatDate(_lastEdited)}",
            //   style: TextStyle(color: Colors.grey, fontSize: 12),
            // ),
          ],
        ),
      ),
    );
  }
}
