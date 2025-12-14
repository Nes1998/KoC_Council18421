import 'package:firebase_database/firebase_database.dart';

Future<Object?> getEventDetails() async {
  // Initialize Firebase Realtime Database reference

  DatabaseReference eventRef = FirebaseDatabase.instance.ref("/");

  DataSnapshot snapshot = await eventRef.get();

  if (snapshot.exists) {
    // Process the event details
    // Example: Extract specific fields from the snapshot and return them
    // ...

    return snapshot.value;
  } else {
    // Handle the case where the event details do not exist
    // ...

    throw Exception("Event details do not exist");
  }
}
