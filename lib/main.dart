import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koc_council_website/calendarEvents/events.dart';
import 'package:koc_council_website/firebase/firebase_options.dart';
import 'package:koc_council_website/routes/login.dart';
import 'package:table_calendar/table_calendar.dart';
import 'firebase/data_management.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KoC Council #18421',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Welcome to KoC Council #18421'),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  late ValueNotifier<List<Events>> _selectedEvents;

  List<Events> _events = [];

  String _csvDownloadResults = '';

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(selectedDay));
    getEventDetails().then((data) {
      // Process the retrieved event db and update _events list

      if (data == null) {
        return;
      } else if (data is Map) {
        data.forEach((key, value) {
          DateTime eventDate = DateTime.parse(value['date']);
          String eventTitle = value['title'];
          String eventDescription = value['description'];

          Events event = Events(
              date: eventDate,
              title: eventTitle,
              description: eventDescription);
          if (!_events.contains(event)) {
            _events.add(event);
          }
        });
      }
    });
  }

  /// Exports the given list of events to a CSV file.
  /// Returns true if the export was successful, false otherwise.
  Future<bool> exportEventsToCSV(List<Events> events) async {
    // Implement the logic to export events to CSV
    List<List<dynamic>> rows = [];

    for (var event in events) {
      rows.add([event.date.toIso8601String(), event.title, event.description]);
    }

    // Convert the rows to CSV string
    String csvData = const ListToCsvConverter().convert(rows);

    // Convert CSV string to bytes
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

    try {
      // Get the directory to save the file
      final directory = await getDownloadsDirectory();
      final path = '${directory?.path}/events.csv';

      // Save the CSV file
      await FileSaver.instance.saveFile(
        name: 'events',
        bytes: bytes,
        filePath: path,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );

      setState(() {
        _csvDownloadResults = 'CSV file saved successfully at $path';
      });

      return true;
    } catch (e) {
      print('Error saving CSV file: $e');

      setState(() {
        _csvDownloadResults = 'Error saving CSV file: $e';
      });

      return false;
    }
  }

  void _showEventDialog(List<Events> events) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Events for ${selectedDay.toIso8601String().substring(0, 10)}'),
          content: SizedBox(
            width: double.maxFinite, // Set width to maximum available
            height: 100, // Fix the height of the dialog
            child: ListView.builder(
              shrinkWrap: true, // Makes list view take only needed space
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].title),
                  subtitle: Text(events[index].description),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text('X')),
            ElevatedButton(
                onPressed: () {
                  exportEventsToCSV(events);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                child: Text('Export events to CSV')),
            if (_csvDownloadResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_csvDownloadResults),
              ),
          ],
        );
      },
    );
  }

  void onFormatChanged(CalendarFormat? format) {
    setState(() {
      _calendarFormat = format!;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);

      if (_selectedEvents.value.isNotEmpty) {
        _showEventDialog(_selectedEvents.value);
      }
    });
  }

  List<Events> _getEventsForDay(DateTime day) {
    // retrive events for the selected day from the database
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
            // TRY THIS: Try changing the color here to a specific color (to
            // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
            // change color while the other colors stay the same.
            backgroundColor: Colors.blue[900],

            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Times New Roman',
                color: Colors.yellow[300],
              ),
            )),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              ElevatedButton(
                  onPressed: () => {Navigator.pushNamed(context, '/login')},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Go to login page',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      )
                    ],
                  )),
              Container(
                  color: Colors.blue[50],
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Faith, Community, Family, Life',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Montserrat'),
                          selectionColor: Color(0xFF6200EE)),
                      FadeInImage(
                        placeholder:
                            const AssetImage('assets/images/koc-logo.png'),
                        image: const AssetImage('assets/images/koc-logo.png'),
                        width: constraints.maxWidth * 0.10,
                        fadeInDuration: const Duration(milliseconds: 100),
                      ),
                      CarouselSlider(
                          items: [
                            Image.asset('assets/images/1000000300.jpg'),
                            Image.asset('assets/images/1000000301.jpg'),
                            Image.asset('assets/images/1000000302.jpg'),
                            Image.asset('assets/images/1000000403.jpg'),
                            Image.asset('assets/images/1000000404.jpg'),
                            Image.asset('assets/images/1000000405.jpg'),
                            Image.asset('assets/images/1000000407.jpg'),
                          ],
                          options: CarouselOptions(
                              height: 200.0,
                              autoPlay: true,
                              enlargeCenterPage: true)),
                      TableCalendar(
                        // include Oratory events as well
                        firstDay: DateTime.utc(2025, 10, 1),
                        focusedDay: focusedDay,
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        selectedDayPredicate: (day) {
                          return isSameDay(selectedDay, day);
                        },
                        onDaySelected: _onDaySelected,
                        onFormatChanged: onFormatChanged,
                        eventLoader: _getEventsForDay,
                        calendarFormat: _calendarFormat,
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    });
  }
}
