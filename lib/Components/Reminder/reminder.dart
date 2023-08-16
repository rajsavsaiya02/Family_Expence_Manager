import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final commanValue cValue = Get.put(commanValue());

class Reminder {
  String id;
  int nid;
  final String title;
  final String description;
  // final String repeatType;
  final DateTime dateTime;

  Reminder({
    required this.id,
    required this.nid,
    required this.title,
    required this.description,
    // required this.repeatType,
    required this.dateTime,
  });
}

class ReminderService {
  final CollectionReference _remindersCollection = FirebaseFirestore.instance
      .collection("users")
      .doc(cValue.currentUser.value.uid.toString())
      .collection('reminders');
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ReminderService() {
    _initNotifications();
  }

  void _initNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Stream<List<Reminder>> getReminders() {
    return _remindersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder(
          id: doc.id,
          nid: doc["nid"],
          title: doc['title'],
          description: doc['description'],
          // repeatType: doc['repeatType'],
          dateTime: DateTime.parse(doc["dateTime"]),
        );
      }).toList();
    });
  }

  int generateRandomNumber() {
    final Random random = Random(DateTime.now().millisecondsSinceEpoch);
    return random.nextInt(99999999);
  }

  Future<void> createReminder(Reminder reminder) async {
    try {
      final DocumentReference docRef = await _remindersCollection.add({
        'title': reminder.title,
        'description': reminder.description,
        // 'repeatType': reminder.repeatType,
        'dateTime': reminder.dateTime,
      });
      final String docId = docRef.id;
      reminder.id = docId;
      _remindersCollection
          .doc(docId)
          .update({'id': docId, 'nid': generateRandomNumber()});
      _scheduleNotification(reminder);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> deleteReminder(String id, int nid) async {
    _remindersCollection.doc(id).delete();
    await _flutterLocalNotificationsPlugin.cancel(nid);
  }

  Future initializetimezone() async {
    tz.initializeTimeZones();
  }

  Duration calculateDateDifference(DateTime enteredDate) {
    final DateTime now = DateTime.now();
    final Duration difference = enteredDate.difference(now);
    return difference;
  }

  void _scheduleNotification(Reminder reminder) async {
    await initializetimezone();
    final String? payload = reminder.title;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(reminder.id, 'Reminder',
            channelDescription: 'Channel for reminder notifications',
            importance: Importance.high,
            playSound: true,
            priority: Priority.high,
            ticker: 'ticker');
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final DateTime dateTime = reminder.dateTime;
    final Duration difference = calculateDateDifference(dateTime);
    final int id = reminder.nid;
    int value = difference.inSeconds;;
    if(value.isNegative){
      value = 3;
    }
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        reminder.title,
        reminder.description,
        await tz.TZDateTime.now(tz.local).add(Duration(seconds: value)),
        platformChannelSpecifics,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
}

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _reminderService = ReminderService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _repeatTypeController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedRepeatType;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection("users")
        .doc(cValue.currentUser.value.uid.toString())
        .collection('reminders');
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        centerTitle: true,
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: query.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData){
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 28,
                              fontWeight: FontWeight.w600),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    // Check if there is no data in the snapshot
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                      return SingleChildScrollView(
                        child: Column(
                          children: documents.map((doc) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(doc["title"]),
                                  subtitle: Text(doc["description"]),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _reminderService.deleteReminder(doc["id"],doc["nid"]);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: SizedBox(
                                    height: 10,
                                    child: Divider(
                                      height: 2,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No data available',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 28,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: primary,
        onPressed: () {
          _showReminderDialog();
        },
      ),
    );
  }

  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Align(alignment: Alignment.center, child: Text('Add Reminder')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // DropdownButtonFormField<String>(
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     hintText: 'Repeat type',
              //   ),
              //   value: _selectedRepeatType,
              //   items: <String>[
              //     'Does not repeat',
              //     'Hourly',
              //     'Daily',
              //     'Weekly',
              //     'Monthly',
              //   ].map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              //   onChanged: (String? value) {
              //     setState(() {
              //       _selectedRepeatType = value;
              //       _repeatTypeController.text = value!;
              //     });
              //   },
              // ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _dateTimeController,
                readOnly: true,
                onTap: () {
                  _selectDateTime();
                },
                decoration: InputDecoration(
                    hintText: 'Date and Time', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      _titleController.text = "";
                      _descriptionController.text = "";
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primary),
                  ),
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: () {
                      final title = _titleController.text;
                      final description = _descriptionController.text;
                      // final repeatType = _repeatTypeController.text;
                      final dateTime = _selectedDateTime;
                      final reminder = Reminder(
                        id: '',
                        nid: 0,
                        title: title,
                        description: description,
                        // repeatType: repeatType,
                        dateTime: dateTime,
                      );
                      _reminderService.createReminder(reminder);
                      _titleController.text = "";
                      _descriptionController.text = "";
                      _selectedDateTime = DateTime.now();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primary),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selectedDateTime != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          _dateTimeController.text = _selectedDateTime.toString();
        });
      }
    }
  }
}
