/// A class similar to http.Response but instead of a String describing the body
/// it already contains the parsed Dart-Object
///
///
///  CAN WE  REMOVE?
class ParsedResponse<T> {
  ParsedResponse(this.statusCode, this.body);

  final int statusCode;
  final T body;

  bool isOk() {
    return statusCode >= 200 && statusCode < 300;
  }
}