import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PastTasksPage extends StatelessWidget {
  final DocumentSnapshot task;

  const PastTasksPage({super.key, required this.task});

  Future<void> _deleteTask(BuildContext context) async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    if (userUID == null) {
      // Handle error if userUID is not available
      print("User not logged in");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('PastTasks')
          .doc(userUID)
          .collection('files')
          .doc(task.id)
          .delete();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: const Text("Deleted successfully!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting task: $e",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var data =
        task['data'] as List<dynamic>; // Adjust based on your data structure

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
        title: const Text(
          'Past Task Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0))),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTask(context),
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(
                label: Text('Column',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Value')),
          ],
          rows: [
            DataRow(cells: [
              const DataCell(
                  Text('R.No', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[0] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Satellite',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[1] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Serial No',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[2] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(
                  Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[3] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Location',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[4] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Carrier Frequency(MHz)',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[5] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Start BT',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[6] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('End BT',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[7] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Start UTC',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[8] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('End UTC',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[9] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(
                  Text('Angle', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(data[10] ?? '')),
            ]),
            DataRow(cells: [
              const DataCell(Text('Received Date and Time',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(task['timestamp'] ?? '')),
            ]),
          ],
        ),
      ),
    );
  }
}
