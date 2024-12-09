import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ssgi/homePage/notificationPage/notification_page.dart';
import 'package:ssgi/homePage/notificationPage/shared_data_users_page.dart';

class SharedDataTables extends StatelessWidget {
  const SharedDataTables({
    super.key,
    required Map<String, dynamic>? selectedNotification,
  }) : _selectedNotification = selectedNotification;

  final Map<String, dynamic>? _selectedNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SharedDataUsersPage()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            DataTable(
              columns: const [
                DataColumn(
                    label: Text('Column',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Value',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('R.No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][0] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Satellite',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][1] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Serial No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][2] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][3] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Location',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][4] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Carrier Frequency(MHz)',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][5] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Start BT',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][6] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('End BT',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][7] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Start UTC',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][8] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('End UTC',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][9] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Angle',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][10] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Received Date and Time',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['timestamp'] ?? '')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationPageDataTable extends StatelessWidget {
  const NotificationPageDataTable({
    super.key,
    required DocumentSnapshot<Object?>? selectedNotification,
  }) : _selectedNotification = selectedNotification;

  final DocumentSnapshot<Object?>? _selectedNotification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            DataTable(
              columns: const [
                DataColumn(
                    label: Text('Column',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Value',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('R.No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][0] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Satellite',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][1] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Serial No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][2] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('No',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][3] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Location',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][4] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Carrier Frequency(MHz)',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][5] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Start BT',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][6] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('End BT',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][7] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Start UTC',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][8] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('End UTC',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][9] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Angle',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['data'][10] ?? '')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Received Date and Time',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_selectedNotification?['timestamp'] ?? '')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
