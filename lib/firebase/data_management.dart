import 'package:firebase_database/firebase_database.dart';

Future<Object?> getEventDetails() async {
  // Initialize Firebase Realtime Database reference

  DatabaseReference eventRef = FirebaseDatabase.instance.ref("events");

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

void setEvent(Object events) async {
  // Initialize Firebase Realtime Database reference
  DatabaseReference eventRef = FirebaseDatabase.instance.ref("events");

  await eventRef.set(events).then((value) {
    // Handle the success case
    print("Event details updated successfully");
  }).catchError((error) {
    // Handle any errors that occur during the update
    print("Error updating event details: $error");
  });
}
