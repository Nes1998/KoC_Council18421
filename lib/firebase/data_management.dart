import 'package:firebase_database/firebase_database.dart';
import 'package:koc_council_website/calendarEvents/events.dart';

Future<Object?> getEventDetails() async {
  // Initialize Firebase Realtime Database reference

  DatabaseReference eventRef = FirebaseDatabase.instance.ref("events");

  DataSnapshot snapshot = await eventRef.get();

  if (snapshot.exists) {
    // Process the event details
    // Example: Extract specific fields from the snapshot and return them
    // ...
    print("Event details retrieved successfully");

    return snapshot.value;
  } else {
    // Handle the case where the event details do not exist
    // ...

    throw Exception("Event details do not exist");
  }
}

void setEvent(Events event) async {
  // Initialize Firebase Realtime Database reference
  DatabaseReference eventRef = FirebaseDatabase.instance.ref("events");

  await eventRef.push().set({
    "date": event.date.toIso8601String(),
    "title": event.title,
    "description": event.description,
    "duration": event.duration,
  }).then((value) {
    // Handle the success case
    print("Event details updated successfully");
  }).catchError((error) {
    // Handle any errors that occur during the update
    print("Error updating event details: $error");
  });
}

void deleteEvent(String eventId) async {
  // Initialize Firebase Realtime Database reference
  DatabaseReference eventRef = FirebaseDatabase.instance.ref("events/$eventId");

  await eventRef.remove().then((value) {
    // Handle the success case
    print("Event deleted successfully");
  }).catchError((error) {
    // Handle any errors that occur during the deletion
    print("Error deleting event: $error");
  });
}
