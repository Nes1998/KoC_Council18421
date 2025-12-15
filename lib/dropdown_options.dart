import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateDropDownMenu extends StatefulWidget {
  final void Function(CalendarFormat?) onChanged;

  DateDropDownMenu({super.key, required this.onChanged});

  @override
  State<DateDropDownMenu> createState() => _DateDropDownMenuState();
}

class _DateDropDownMenuState extends State<DateDropDownMenu> {
  final TextEditingController optionController = TextEditingController();

  CalendarFormat selectedOption = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<CalendarFormat>(
        value: selectedOption,
        onChanged: (CalendarFormat? newValue) {
          setState(() {
            selectedOption = newValue!;
            widget.onChanged(newValue);
          });
        },
        items: [
          DropdownMenuItem(value: CalendarFormat.month, child: Text('Month')),
          DropdownMenuItem(value: CalendarFormat.week, child: Text('Week')),
          DropdownMenuItem(
              value: CalendarFormat.twoWeeks, child: Text('Two Weeks')),
        ]);
  }
}
