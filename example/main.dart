import 'package:requests_plus/requests_plus.dart';

void main(List<String> arguments) async {
  // This example uses the Google Books API to search for books about requests.
  // https://developers.google.com/books/docs/overview
  var url = 'https://www.googleapis.com/books/v1/volumes?q={requests}';

  // Await the http get response, then decode the json-formatted response.
  var response = await RequestsPlus.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = response.json();
    var itemCount = jsonResponse["totalItems"];
    print('Number of books about requests: $itemCount.');
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}
