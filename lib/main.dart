import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koc_council_website/calendarEvents/events.dart';
import 'package:koc_council_website/firebase/firebase_options.dart';
import 'package:koc_council_website/google_api.dart';
import 'package:koc_council_website/routes/login.dart';
import 'package:table_calendar/table_calendar.dart';
import 'firebase/data_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  await dotenv.load(fileName: ".env");
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
  GoogleHttpClient? _googleHttpClient = GoogleHttpClient({
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  });
  Events? selectedEvent; // Initialize with default values

  List<Events> _events = [];

  Events? defaultEvent; // Initialize with default values

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
          int eventDuration =
              value['duration'] ?? 0; // Default to 0 if not provided

          Events event = Events(
              id: key,
              date: eventDate,
              title: eventTitle,
              description: eventDescription,
              duration: eventDuration);
          if (!_events.contains(event)) {
            _events.add(event);
          }
        });

        selectedEvent = Events(
            id: '',
            date: DateTime.now(),
            title: '',
            description: '',
            duration: 0); // Initialize with default values
      }
    });
  }

  void _showEventDialog(List<Events> events) {
    events.sort((a, b) => a.date.compareTo(b.date));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Events for ${selectedDay.toIso8601String().substring(0, 10)}'),
          content: SizedBox(
            width: double.maxFinite, // Set width to maximum available
            height: 300, // Fix the height of the dialog
            child: ListView.builder(
              shrinkWrap: true, // Makes list view take only needed space
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].title),
                  subtitle: Text(events[index].description),
                  selected: selectedEvent == events[index],
                  onTap: () {
                    setState(() {
                      selectedEvent = events[index];
                      return;
                    });
                  },
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
                  try {
                    _googleHttpClient?.insertGoogleCalendarEvent(
                        selectedEvent!.date,
                        selectedEvent!.title,
                        selectedEvent!.description,
                        selectedEvent!.duration);
                  } catch (e) {
                    print('Error adding event to Google Calendar: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                child: Text('Add to your google calendar')),
            if (FirebaseAuth.instance.currentUser != null)
              ElevatedButton(
                  onPressed: () {
                    addEvents(selectedDay);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  child: Text('Add Events')),
            if (FirebaseAuth.instance.currentUser != null)
              ElevatedButton(
                  onPressed: () {
                    deleteEvent(selectedEvent!.id);
                    setState(() {
                      _events.remove(selectedEvent);
                      _selectedEvents.value.remove(selectedEvent);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent),
                  child: Text('Delete Events'))
          ],
        );
      },
    );
  }

  void addEvents(DateTime eventDate) {
    String title = '';
    String description = '';
    DateTime date = eventDate;
    TextEditingController dateController = TextEditingController();
    int duration = 0;

    void selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        final DateTime pickedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime?.hour ?? 0,
          pickedTime?.minute ?? 0,
        );

        String? formattedDate =
            DateFormat('dd/MM/yyyy HH:mm:ss').format(pickedDateTime);
        setState(() {
          date = pickedDateTime;
          dateController.text = formattedDate;
        });
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Event'),
            content: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Event Title'),
                  onChanged: (value) => title = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Event Description'),
                  onChanged: (value) => description = value,
                ),
                TextFormField(
                  controller: dateController,
                  readOnly:
                      true, // Prevents manual entry and keyboard appearance
                  decoration: InputDecoration(
                    labelText: 'Event Date',
                    hintText: 'DD/MM/YYYY HH:MM:SS',
                    suffixIcon: Icon(
                        Icons.calendar_today), // Optional: Add a calendar icon
                  ),
                  onTap: () {
                    selectDate(context);
                  },
                  validator: (value) {
                    // Optional: Add form validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter the event date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Event Duration (hours)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Optional: Add validation for numeric input
                    if (int.tryParse(value) != null) {
                      setState(() {
                        duration = int.parse(value);
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    // Logic to add event
                    Events newEvent = Events(
                        id: '',
                        date: date,
                        title: title,
                        description: description,
                        duration: duration);
                    setEvent(newEvent);
                    setState(() {
                      _events.add(newEvent);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent),
                  child: Text('Add Event')),
            ],
          );
        });
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
      } else if (FirebaseAuth.instance.currentUser != null) {
        addEvents(selectedDay);
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
