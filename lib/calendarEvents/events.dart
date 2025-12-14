class Events {
  DateTime date = DateTime.now();
  String title = "";

  Events({required this.date, required this.title});

  void displayEvent() {
    print("Event: $title");
    print("Date: ${date.year}-${date.month}-${date.day}");
  }

  void updateEvent(String newTitle, DateTime newDate) {
    title = newTitle;
    date = newDate;
  }

  void deleteEvent() {
    // Implement the logic to delete the event
    print("Event deleted: $title");
  }
}
