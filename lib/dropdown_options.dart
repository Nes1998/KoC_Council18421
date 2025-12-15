import 'dart:collection';

import 'package:flutter/material.dart';

typedef DropdownEntries = DropdownMenuEntry<DropdownOptions>;

enum DropdownOptions {
  week("week"),
  twoWeeks("2 weeks"),
  month("month"),
  year("year");

  const DropdownOptions(this.title);
  final String title;

  static final List<DropdownEntries> menuEntries =
      UnmodifiableListView<DropdownEntries>(values.map<DropdownEntries>(
          (DropdownOptions entry) => DropdownEntries(
              value: entry,
              label: entry.title,
              style: MenuItemButton.styleFrom(
                  foregroundColor: Colors.lightBlueAccent))));
}

class DropdownMenu extends StatefulWidget {
  const DropdownMenu({super.key});

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  final TextEditingController optionController = TextEditingController();
  DropdownOptions? selectedOption;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DropdownOptions>(
      value: selectedOption,
      onChanged: (DropdownOptions? newValue) {
        setState(() {
          selectedOption = newValue;
        });
      },
      items: DropdownOptions.menuEntries.map<DropdownMenuItem<DropdownOptions>>(
          (DropdownMenuEntry<DropdownOptions> entry) {
        return DropdownMenuItem<DropdownOptions>(
          value: entry.value,
          child: Text(entry.label),
        );
      }).toList(),
    );
  }
}
