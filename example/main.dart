import 'dart:developer';

import 'package:requests/requests.dart';

void main(List<String> arguments) async {
  // This example uses the Google Books API to search for books about requests.
  // https://developers.google.com/books/docs/overview
  const url = 'https://www.googleapis.com/books/v1/volumes?q={requests}';

  // Await the http get response, then decode the json-formatted response.
  final response = await Requests.get(url);
  if (response.statusCode == 200) {
    final jsonResponse = response.json();
    final itemCount = jsonResponse['totalItems'];
    log('Number of books about requests: $itemCount.');
  } else {
    log('Request failed with status: ${response.statusCode}');
  }
}
