import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koc_council_website/calendarEvents/events.dart';
import 'firebase/firebase_options.dart';
import 'package:table_calendar/table_calendar.dart';
import 'firebase/data_management.dart';
import 'package:koc_council_website/dropdown_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  List<Events> _events = [
    Events(
        date: DateTime(2025, 11, 1),
        title: "Tootsie roll drive",
        description:
            "Charity drive for the knights council of Old Saint Patrick's Oratory; proceeds go to local charities for those with developmental disabilities. God bless!"),
    Events(
        date: DateTime(2025, 11, 22),
        title: "Canon Bivouli's Anniversary Mass",
        description:
            "Come join us for a special anniversary Mass to celebrate Canon Bivouli's 10th anniversary of his Ordination. God bless!"),
    Events(
        date: DateTime(2025, 12, 18),
        title: "Knights Christmas Movie Night -  It's a Wonderful Life",
        description:
            "Join us for a special movie night with the Knights council of Old Saint Patrick's Oratory. We will be showing 'It's a Wonderful Life' at the Parish Hall. We will have popcorn and potluck style dishes. God bless!"),
  ];

  @override
  void initState() {
    super.initState();
    selectedDay = focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(selectedDay));
    for (var event in _events) {
      setEvent(event);
    }
  }

  void _showEventDialog(Events event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: Text(event.description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('X'),
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
        _showEventDialog(_selectedEvents.value.first);
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
              style: TextStyle(
                fontFamily: 'Times New Roman',
                color: Colors.yellow[300],
              ),
            )),
        body: Center(
          child: Container(
              color: Colors.blue[50],
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Faith, Community, Family, Life',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Montserrat'),
                      selectionColor: Color(0xFF6200EE)),
                  FadeInImage(
                    placeholder: const AssetImage('assets/images/koc-logo.png'),
                    image: const AssetImage('assets/images/koc-logo.png'),
                    width: constraints.maxWidth * 0.25,
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
                  DateDropDownMenu(onChanged: onFormatChanged),
                  TableCalendar(
                    // include Oratory events as well
                    firstDay: DateTime.utc(2025, 10, 1),
                    focusedDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    onDaySelected: _onDaySelected,
                    onFormatChanged: onFormatChanged,
                    eventLoader: _getEventsForDay,
                    calendarFormat: _calendarFormat,
                  ),
                ],
              )),
        ),
      );
    });
  }
}
