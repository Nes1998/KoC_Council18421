class Events {
  String id = "";
  DateTime date = DateTime.now();
  String title = "";
  String description = "";
  int duration = 0; // Duration in hours

  Events(
      {required this.id,
      required this.date,
      required this.title,
      this.description = '',
      this.duration = 0});

  void displayEvent() {
    print("Event: $title");
    print("Date: ${date.year}-${date.month}-${date.day}");
    print("Description: $description");
  }

  void updateEvent(String newTitle, DateTime newDate, String newDescription) {
    title = newTitle;
    date = newDate;
    description = newDescription; // Update the description if provided
  }

  void deleteEvent(String eventId) {
    // Implement the logic to delete the event
    print("Event deleted: $title");
  }
}
