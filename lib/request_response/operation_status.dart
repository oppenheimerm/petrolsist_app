class OperationStatus{
  bool success = false;
  String? errorMessage;

  OperationStatus(bool success, String? errorMessage)
  {
    success = success;
    errorMessage = errorMessage;
  }
}