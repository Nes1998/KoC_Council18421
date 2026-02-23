import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

class GoogleApi {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1037162977977-3f88207vtvbig3s33eca8tk0li6gk60h.apps.googleusercontent.com',
    scopes: [calendar.CalendarApi.calendarScope],
  );
  Future<GoogleSignInAccount?> _handleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print(error);
      return null;
    }
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  Future<void> insertGoogleCalendarEvent(DateTime eventStartTime, String title,
      String description, int duration) async {
    var googleApi = GoogleApi();
    final googleUser = await googleApi._handleSignIn();
    if (googleUser == null) return;

    final authHeaders = await googleUser.authHeaders;
    final authenticatedClient = GoogleHttpClient(authHeaders);
    final calendarApi = calendar.CalendarApi(authenticatedClient);

    final event = calendar.Event(
      summary: title,
      description: description,
      start: calendar.EventDateTime(
        dateTime: eventStartTime,
        timeZone: 'America/Chicago', // Set to user's local time zone
      ),
      end: calendar.EventDateTime(
        dateTime: eventStartTime.add(Duration(hours: duration)),
        timeZone: 'America/Chicago',
      ),
    );

    try {
      await calendarApi.events.insert(
          event, 'primary'); // 'primary' refers to the user's main calendar
      print('Event created successfully!');
    } catch (e) {
      print('Error creating event: $e');
    } finally {
      authenticatedClient.close();
    }
  }
}
