class Events {
  DateTime date = DateTime.now();
  String title = "";
  String description = "";

  Events({required this.date, required this.title, this.description = ""});

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

  void deleteEvent() {
    // Implement the logic to delete the event
    print("Event deleted: $title");
  }
}
