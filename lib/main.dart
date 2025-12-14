import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koc_council_website/calendarEvents/events.dart';
import 'firebase/firebase_options.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database/data_reader.dart';

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

  Map<DateTime, List<Events>> _events = {};

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
    });
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
                    focusedDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    onDaySelected: _onDaySelected,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.twoWeeks: '2 Weeks',
                      CalendarFormat.week: 'Week',
                    },
                  ),
                ],
              )),
        ),
      );
    });
  }
}
